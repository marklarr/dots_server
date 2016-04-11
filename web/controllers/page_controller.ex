defmodule DotsServer.PageController do
  use DotsServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
