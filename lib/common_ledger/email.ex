defmodule CommonLedger.Email do
  import Swoosh.Email

  def deliver_login_link(user, url) do
    new()
    |> to({user.name || "User", user.email})
    |> from({"CommonLedger", "noreply@commonledger.example.com"})
    |> subject("Login to CommonLedger")
    |> html_body("""
    <h1>Welcome to CommonLedger!</h1>
    <p>Click the link below to log in to your account:</p>
    <p><a href="#{url}">Log in to CommonLedger</a></p>
    <p>If you didn't request this login link, please ignore this email.</p>
    """)
    |> text_body("""
    Welcome to CommonLedger!

    Click the link below to log in to your account:
    #{url}

    If you didn't request this login link, please ignore this email.
    """)
    |> CommonLedger.Mailer.deliver()
  end
end
