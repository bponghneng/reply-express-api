defmodule ReplyExpressWeb.Router do
  use ReplyExpressWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:reply_express, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ReplyExpressWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope path: "/api/v1", alias: ReplyExpressWeb.API.V1 do
    pipe_through [:api]

    scope path: "/users", alias: Users do
      # User authentication
      post "/log_in", SessionController, :create
      post "/register", RegistrationController, :create
    end
  end
end
