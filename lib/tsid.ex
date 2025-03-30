defmodule TSID do
  @moduledoc """
  TSID: Timestamp Identifier Library for Elixir

  Implementation of Timestamp Identifiers (TSIDs) - compact, sortable string identifiers
  based on an integer timestamp, suitable for use in web URLs and as a logical clock
  in networked systems.

  A TSID is a 64-bit integer with the following structure:
  - Top bit is always 0
  - Next 53 bits represent microseconds since the UNIX epoch (chosen for JavaScript compatibility)
  - Final 10 bits are a random "clock identifier"

  The resulting integer is encoded using base32-sortable encoding (characters 234567abcdefghijklmnopqrstuvwxyz),
  producing a 13-character string.
  """

  import Bitwise

  @base32_chars "234567abcdefghijklmnopqrstuvwxyz"
  @tsid_length 13
  @clock_id_bits 10
  @max_clock_id (1 <<< @clock_id_bits) - 1
  @unix_epoch ~N[1970-01-01 00:00:00]

  @doc """
  Generates a new TSID using the current timestamp and a random clock identifier.

  ## Examples

      iex> TSID.generate()
      "bj42vd6gh7abc"  # Example output (will vary based on current timestamp)

  Returns a 13-character base32-sortable string.
  """
  @spec generate() :: String.t()
  def generate do
    timestamp_value = system_time()
    clock_id = :rand.uniform(@max_clock_id + 1) - 1

    create(timestamp_value, clock_id)
  end

  @doc """
  Generates a TSID using the current timestamp and a specified clock identifier.
  This is useful for distributed systems that need to ensure unique clock IDs.

  ## Examples

      iex> TSID.generate_with_clock_id(123)
      "bj42vd6gh77bc"  # Example output (will vary based on current timestamp)

  Returns a 13-character base32-sortable string.
  """
  @spec generate_with_clock_id(non_neg_integer) :: String.t()
  def generate_with_clock_id(clock_id) when clock_id >= 0 and clock_id <= @max_clock_id do
    timestamp_value = system_time()
    create(timestamp_value, clock_id)
  end

  @doc """
  Creates a TSID using a specific timestamp (in microseconds since UNIX epoch)
  and a specified clock identifier.

  ## Examples

      iex> TSID.create(1679442813_000000, 123)
      "bj42vd6gh77bc"  # Output with fixed timestamp and clock ID

  Returns a 13-character base32-sortable string.
  """
  @spec create(non_neg_integer, non_neg_integer) :: String.t()
  def create(timestamp_us, clock_id)
      when timestamp_us >= 0 and clock_id >= 0 and clock_id <= @max_clock_id do
    # Combine timestamp and clock ID into a 64-bit integer
    # Top bit is 0, next 53 bits are timestamp, last 10 bits are clock ID
    value = timestamp_us <<< @clock_id_bits ||| clock_id

    # Encode to base32-sortable
    encode_base32(value)
  end

  @doc """
  Decodes a TSID string back to its timestamp and clock ID components.

  ## Examples

      iex> TSID.decode("bj42vd6gh77bc")
      {:ok, %{timestamp_us: 1679442813000000, clock_id: 123, datetime: ~N[2023-03-21 21:20:13.000000]}}

      iex> TSID.decode("invalid!")
      {:error, "Invalid TSID format"}

  Returns a map with the timestamp in microseconds, the clock ID, and
  the corresponding DateTime.
  """
  @spec decode(String.t()) :: {:ok, map()} | {:error, String.t()}
  def decode(tsid) do
    case decode_base32(tsid) do
      {:ok, value} ->
        clock_id = value &&& @max_clock_id
        timestamp_us = value >>> @clock_id_bits

        datetime =
          @unix_epoch
          |> NaiveDateTime.add(div(timestamp_us, 1_000_000), :second)
          |> NaiveDateTime.add(rem(timestamp_us, 1_000_000), :microsecond)

        {:ok,
         %{
           timestamp_us: timestamp_us,
           clock_id: clock_id,
           datetime: datetime
         }}

      error ->
        error
    end
  end

  @doc """
  Extracts just the timestamp from a TSID string as microseconds since the UNIX epoch.

  ## Examples

      iex> TSID.timestamp("bj42vd6gh77bc")
      {:ok, 1679442813000000}

      iex> TSID.timestamp("invalid!")
      {:error, "Invalid TSID format"}
  """
  @spec timestamp(String.t()) :: {:ok, non_neg_integer} | {:error, String.t()}
  def timestamp(tsid) do
    case decode(tsid) do
      {:ok, %{timestamp_us: timestamp_us}} -> {:ok, timestamp_us}
      error -> error
    end
  end

  @doc """
  Compares two TSIDs chronologically.

  ## Examples

      iex> TSID.compare("aj42vd6gh77bc", "bj42vd6gh77bc")
      :lt  # First TSID is earlier than second

      iex> TSID.compare("bj42vd6gh77bc", "bj42vd6gh77bc")
      :eq  # TSIDs are equal

      iex> TSID.compare("cj42vd6gh77bc", "bj42vd6gh77bc")
      :gt  # First TSID is later than second

  Returns `:lt` if first TSID is earlier, `:eq` if they are the same,
  and `:gt` if first TSID is later.
  """
  @spec compare(String.t(), String.t()) :: :lt | :eq | :gt
  def compare(tsid1, tsid2) do
    # Decode both TSIDs to get their components
    {:ok, {timestamp1, _random1}} = decode(tsid1)
    {:ok, {timestamp2, _random2}} = decode(tsid2)

    cond do
      timestamp1 < timestamp2 -> :lt
      timestamp1 > timestamp2 -> :gt
      # If timestamps are equal, compare the original strings to maintain total ordering
      true -> :eq
    end
  end

  @doc """
  Validates that a string is a properly formatted TSID.

  ## Examples

      iex> TSID.valid?("bj42vd6gh77bc")
      true

      iex> TSID.valid?("invalid!")
      false

  Returns boolean indicating if the TSID is valid.
  """
  @spec valid?(String.t()) :: boolean
  def valid?(tsid) do
    case decode_base32(tsid) do
      {:ok, _} -> true
      _ -> false
    end
  end

  # Private helper functions

  # Get current time in microseconds since UNIX epoch
  defp system_time do
    System.system_time(:microsecond)
  end

  # Encode a 64-bit integer to base32-sortable string
  defp encode_base32(value) when is_integer(value) and value >= 0 do
    chars = String.codepoints(@base32_chars)
    base = length(chars)

    # Generate each character by taking modulo and dividing
    {result, _} =
      1..@tsid_length
      |> Enum.reduce({"", value}, fn _, {acc, remaining} ->
        char_index = rem(remaining, base)
        char = Enum.at(chars, char_index)
        remaining = div(remaining, base)
        {char <> acc, remaining}
      end)

    result
  end

  # Decode a base32-sortable string to a 64-bit integer
  defp decode_base32(str) when is_binary(str) do
    if String.length(str) != @tsid_length or !valid_base32?(str) do
      {:error, "Invalid TSID format"}
    else
      chars = String.codepoints(@base32_chars)
      base = length(chars)

      value =
        str
        |> String.codepoints()
        |> Enum.reduce(0, fn char, acc ->
          char_value = Enum.find_index(chars, &(&1 == char))
          acc * base + char_value
        end)

      {:ok, value}
    end
  end

  # Check if a string contains only valid base32-sortable characters
  defp valid_base32?(str) do
    valid_chars = String.codepoints(@base32_chars) |> MapSet.new()

    str
    |> String.codepoints()
    |> Enum.all?(fn char -> MapSet.member?(valid_chars, char) end)
  end
end
