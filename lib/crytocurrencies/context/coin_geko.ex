defmodule Crytocurrencies.Context.CoinGeko do
  alias Poision

  def fetch_data(operation, value) do
    case operation do
      "search_by_name" ->
        get_data("https://api.coingecko.com/api/v3/search?query=#{value}", value)

      "search_by_id" ->
        get_data("https://api.coingecko.com/api/v3/coins/#{value}", value)

      "get_last_14day_data" ->
        get_data("https://api.coingecko.com/api/v3/coins/#{value}/market_chart?vs_currency=usd&days=14&interval=24", value)
      _ ->
        {:error, "un-suppoprted get operation!!!"}
    end
  end

  defp get_data(url, value) do
    case HTTPoison.get(url, [], timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found #{value} details :("}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Sorry, Ooops something went wrong!!!", reason}
    end
  end
end
