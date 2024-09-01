defmodule ReplyExpress.Auth do
  @moduledoc """
  Boundary for authentication. Uses the Pbkdf2 password hashing function.
  """

  def hash_password(password), do: Pbkdf2.hash_pwd_salt(password)

  def validate_password(password, hashed_password),
    do: Pbkdf2.verify_pass(password, hashed_password)
end
