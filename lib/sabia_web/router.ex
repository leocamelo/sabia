defmodule SabiaWeb.Router do
  use SabiaWeb, :router

  import SabiaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SabiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sabia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SabiaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SabiaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SabiaWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/signup", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
      live "/reset-password", UserForgotPasswordLive, :new
      live "/reset-password/:token", UserResetPasswordLive, :edit
    end

    post "/login", UserSessionController, :create
  end

  scope "/", SabiaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SabiaWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm-email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", SabiaWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SabiaWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new

      live "/", PostLive.Index
      live "/fofoca/:id", PostLive.Show
    end
  end
end
