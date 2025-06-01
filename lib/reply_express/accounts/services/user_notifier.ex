defmodule ReplyExpress.Accounts.Services.UserNotifier do
  @moduledoc """
  Provides functions to send notifications to users, such as password reset instructions,
  using the application's mailer service.
  """

  import Swoosh.Email

  alias ReplyExpress.Mailer

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions({name, _email} = to, url, token) do
    deliver(to, "Reset password instructions", """

    ==============================

    Hi #{name},

    You can reset your password by visiting the URL below:

    #{url}?token=#{token}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"ReplyExpress", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
