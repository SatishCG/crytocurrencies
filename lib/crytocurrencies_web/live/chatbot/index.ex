defmodule CrytocurrenciesWeb.Live.Chatbot.Index do
  @moduledoc false

  use CrytocurrenciesWeb, :live_view

  alias Crytocurrencies.Context.CoinGeko
  alias Poision

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(conversations: [])
      |> assign(form: %{})
      |> assign(name: nil)
      |> assign(disabled: false)
      |> assign(next_operation: nil)
      |> assign(operation: nil)
    }
  end

  @impl true
  def handle_event("save", %{"name" => name} = _params, socket) do
    conversations = [{:chatbot, "<div>Welcome #{name}</div>"}]

    option = "
        <div>please click on following option to search coin ? </div>
        <div class='mt-4'>
          <button phx-click='operation_search_by_name' class='px-4 py-2 bg-primary-100 disabled:bg-gray-100'> Search By Name </button>
          <button phx-click='operation_search_by_id' class='px-4 py-2 bg-primary-100 disabled:bg-gray-100 ml-4'> Search By ID </button>
        </div>
      "

    {
      :noreply,
      socket
      |> assign(name: name)
      |> assign(conversations: conversations)
      |> assign(next_operation: option)
      |> assign(disabled: true)
    }
  end

  def handle_event("operation_" <> operation, _params, socket) do
    %{conversations: conversations, next_operation: next_operation} = socket.assigns

    socket =
      socket
      |> assign(disabled: false)
      |> assign(next_operation: nil)

    conversations =
      if next_operation != nil do
        conversations ++ [{:chatbot, next_operation}]
      else
        conversations
      end

    socket =
      case operation do
        "search_by_name" ->
          socket
          |> assign(operation: "search_by_name")
          |> assign(next_operation: nil)
          |> assign(
            conversations:
              conversations ++ [{:user, "<div>you choosed search by name option</div>"}]
          )

        "search_by_id" ->
          socket
          |> assign(operation: "search_by_id")
          |> assign(next_operation: nil)
          |> assign(
            conversations:
              conversations ++ [{:user, "<div>you choosed search by id option</div>"}]
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("get_last_14day_data_" <> coin_id, _param, socket) do
    %{conversations: conversations, next_operation: next_operation} = socket.assigns

    response = parse_status("get_last_14day_data", CoinGeko.fetch_data("get_last_14day_data", coin_id))

    result = [
      {:chatbot, next_operation},
      {:user, "<div>get #{coin_id} coin last 14 day data</div>"}
    ]

    result =
      case response do
        {:ok, response} ->
          result ++ [{:chatbot, response}]

        {:error, msg} ->
          result ++ [{:chatbot, msg}]
      end

    socket =
      socket
      |> assign(conversations: conversations ++ result)

    {
      :noreply,
      socket
      |> assign(next_operation: "close")
    }
  end

  def handle_event(_event, %{"search" => search}, socket) do
    %{conversations: conversations, operation: operation} = socket.assigns

    socket =
      case operation do
        "search_by_name" ->
          response = parse_status(operation, CoinGeko.fetch_data(operation, search))
          conversations = conversations ++ [{:user, "<div>searching #{search}</div>"}]

          case response do
            {:ok, response} ->
              socket
              |> assign(conversations: conversations)
              |> assign(next_operation: response)
              |> assign(disabled: true)

            {:error, msg} ->
              socket
              |> assign(conversations: conversations ++ [{:chatbot, msg}])
          end

        "search_by_id" ->
          response = parse_status(operation, CoinGeko.fetch_data(operation, search))

          case response do
            {:ok, response} ->
              socket
              |> assign(conversations: conversations)
              |> assign(next_operation: response)
              |> assign(disabled: true)

            {:error, msg} ->
              socket
              |> assign(conversations: conversations ++ [{:chatbot, msg}])
          end
      end

    {:noreply, socket}
  end

  def parse_status(operation, response) do
    case response do
      {:ok, values} ->
        transform_response(operation, values)

      {:error, msg} ->
        {:error, msg}

      {:error, msg, _reason} ->
        {:error, msg}
    end
  end

  def transform_response("search_by_id", response) do
    coin_id = response["id"]
    name = response["name"]
    thumb_url = response["image"]["thumb"]

    result = "
      <div class='mt-1'>
        <div class=' grid grid-cols-5 gap-4'>
          <button phx-click='get_last_14day_data_#{coin_id}' class='px-4 py-2 disabled:bg-gray-100 mr-4 flex'>
            <img src='#{thumb_url}' alt='#{name}' class='w-8 h-8'> <span class='ml-2'>#{name}</span>
          </button>
        </div>
        <div class='mt-2'> click on above coin option to view last 14 days data </div>
      </div>
    "

    {:ok, result}
  end

  def transform_response("get_last_14day_data", response) do
    value = Poison.encode!(response)
    result = "
        <div class='mt-4'>
          <textarea rows='8' cols='100'>
          #{value}
          </textarea>
        </div>
      "

    {:ok, result}
  end

  def transform_response("search_by_name", response) do
    result =
      Map.get(response, "coins", [])
      |> Enum.map(fn coin ->
        coin_id = coin["id"]
        name = coin["name"]
        thumb_url = coin["thumb"]

        "<button phx-click='get_last_14day_data_#{coin_id}' class='px-4 py-2 disabled:bg-gray-100 mr-4 flex'>
          <img src='#{thumb_url}' alt='#{name}' class='w-8 h-8'> <span class='ml-2'>#{name}</span>
        </button>"
      end)
      |> Enum.join("")

    result = "
      <div class='mt-1'>
        <div class=' grid grid-cols-5 gap-4'>#{result}</div>
        <div class='mt-2'> click on above coin option to view last 14 days data </div>
      </div>
      "
    {:ok, result}
  end

  def transform_response(_operation, _response) do
    {:error, "unsupported response"}
  end

  def chatbot_form(assigns) do
    assigns =
      assigns
      |> assign_new(:placeholder, fn -> "" end)
      |> assign_new(:values, fn -> [] end)

    ~H"""
      <.form let={f} for={@form} phx-submit={@event} >
        <%= text_input(f, @key, required: true, placeholder: @placeholder, class: "w-5/6 disabled:bg-gray-100") %>
        <%= submit("Proceed", class: " px-8 py-2 bg-primary-100 disabled:bg-gray-100") %>
      </.form>
    """
  end
end
