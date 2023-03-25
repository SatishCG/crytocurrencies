defmodule CrytocurrenciesWeb.CoinGekoTest do
  use ExUnit.Case

  alias Crytocurrencies.Context.CoinGeko

  describe "Get Geko Coin Details" do
    test "search coin by name", %{} do
      assert {:ok, _} = CoinGeko.fetch_data("search_by_name", "Bitcoin")
    end

    test "search coin by id", %{} do
      assert {:ok, _} = CoinGeko.fetch_data("search_by_id", "bitcoin")
    end

    test "get last 14 day coin price data", %{} do
      assert {:ok, _} = CoinGeko.fetch_data("get_last_14day_data", "bitcoin")
    end
  end
end
