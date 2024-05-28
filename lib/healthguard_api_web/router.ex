defmodule HealthguardApiWeb.Router do
  use HealthguardApiWeb, :router

  import HealthguardApiWeb.UserAuth
  alias HealthguardApi.Credentials

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HealthguardApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    # plug HealthguardApiWeb.Plugs.Context
  end

  pipeline :admins_only do
    plug :admin_basic_auth
  end

  scope "/api" do
    pipe_through [:api, :admins_only]

    forward "/graphql", Absinthe.Plug, schema: HealthguardApiWeb.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: HealthguardApiWeb.Schema
  end

  scope "/", HealthguardApiWeb do
    pipe_through [:browser, :admins_only]

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:healthguard_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HealthguardApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HealthguardApiWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HealthguardApiWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/test/users", TestUsers
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HealthguardApiWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HealthguardApiWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", HealthguardApiWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HealthguardApiWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  defp admin_basic_auth(conn, _opts) do
    credentials = Credentials.get_admin_credentials()
    username = credentials.admin_username
    password = credentials.admin_password
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
