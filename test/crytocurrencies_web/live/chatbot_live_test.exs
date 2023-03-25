defmodule CrytocurrenciesWeb.ChatbotLiveTest do
  use CrytocurrenciesWeb.ConnCase
  use ExUnit.Case

  import Phoenix.LiveViewTest

  defp create_socket() do
    %{socket: %Phoenix.LiveView.Socket{}}
  end

  describe "Socket state" do
    setup do
      create_socket()
    end

    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200)

      {:ok, view, _html} = live(conn)

      assert view.module == CrytocurrenciesWeb.Live.Chatbot.Index
    end
  end
end
