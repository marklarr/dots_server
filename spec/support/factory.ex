defmodule DotsServer.Factory do
  use ExMachina.Ecto, repo: DotsServer.Repo

  alias DotsServer.User

  def factory(:user) do
    %User{
      handle: "d0t1n4t0r",
      email: sequence(:email, &"email-#{&1}@fake.com"),
      encrypted_password: :crypto.hash(:sha256, "my_pass123") |> Base.encode16
    }
  end
end
