defmodule CrytocurrenciesWeb.PageController do
  use CrytocurrenciesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
