defmodule DotsServer.UserView do
  use DotsServer.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, DotsServer.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, DotsServer.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    Poison.decode!(Poison.encode!(user))
  end
end
