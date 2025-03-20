defmodule CommonLedgerWeb.Router do
  use CommonLedgerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CommonLedgerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CommonLedgerWeb do
    pipe_through :browser

    get "/", GroupController, :index
    
    # Auth routes
    get "/auth/login", AuthController, :new
    post "/auth/login", AuthController, :login
    get "/auth/verify", AuthController, :verify_form
    post "/auth/verify", AuthController, :verify
    delete "/auth/logout", AuthController, :logout

    # Group routes
    resources "/groups", GroupController
    get "/groups/:id/add_member", GroupController, :add_member_form
    post "/groups/:id/add_member", GroupController, :add_member
    delete "/groups/:id/members/:user_id", GroupController, :remove_member
  end

  # Other scopes may use custom stacks.
  # scope "/api", CommonLedgerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:common_ledger, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CommonLedgerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp fetch_current_user(conn, _opts) do
    if user_token = get_session(conn, :user_token) do
      user = CommonLedger.Accounts.get_user_by_session_token(user_token)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end
