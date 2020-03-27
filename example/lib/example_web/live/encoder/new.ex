defmodule ExampleWeb.Live.Encoder.New do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias RotaryEncoder.Monitor

  def render(assigns) do
    Phoenix.View.render(ExampleWeb.PageView, "form.html", assigns)
  end

  def mount(_params, %{}, socket) do
    {:ok, initialize_socket(socket)}
  end

  defp initialize_socket(socket) do
    socket
    |> assign(name: "")
    |> assign(
      error_message: "",
      encoder_a_pin: "",
      encoder_b_pin: "",
      button_pin: "",
      btn_default_state: "normally_open"
    )
  end

  def handle_event("add-encoder", params, socket) do
    socket =
      case check_params(params) do
        {:ok,
         %{
           "button_pin" => button_pin,
           "encoder_a_pin" => encoder_a_pin,
           "encoder_b_pin" => encoder_b_pin,
           "btn_default_state" => btn_default_state,
           "name" => name
         }} ->
          enc = %{
            name: name,
            encoder_a_pin: safer_to_integer(encoder_a_pin),
            encoder_b_pin: safer_to_integer(encoder_b_pin),
            button_pin: safer_to_integer(button_pin),
            btn_default_state: String.to_existing_atom(btn_default_state)
          }

          Monitor.monitor_encoder(enc)
          socket = decorate_socket(enc, socket)

          assign(socket, :error_message, "")

        {:error, msg} ->
          assign(socket, :error_message, msg)
      end

    {:noreply, socket}
  end

  defp check_params(
         %{
           "button_pin" => "",
           "encoder_a_pin" => "",
           "encoder_b_pin" => "",
           "name" => ""
         } = params
       ) do
    {:ok, params}
  end

  defp check_params(params) do
    with {:ints, true} <- {:ints, check_for_ints(params)},
         {:name, true} <- {:name, check_for_name(params)},
         {:name_uniq, true} <- {:name_uniq, check_for_name_uniquness(params)},
         {:enc, true} <- {:enc, check_for_encoder(params)} do
      {:ok, params}
    else
      {:ints, false} ->
        {:error, "all pin inputs must be ints"}

      {:name, false} ->
        {:error, "you must provide a name"}

      {:name_uniq, false} ->
        {:error, "the name is already in use"}

      {:enc, false} ->
        {:error, "both encoder pins must be provided"}
    end
  end

  defp check_for_ints(%{
         "button_pin" => button_pin,
         "encoder_a_pin" => encoder_a_pin,
         "encoder_b_pin" => encoder_b_pin
       }) do
    empty_or_int?(button_pin) &&
      empty_or_int?(encoder_a_pin) &&
      empty_or_int?(encoder_b_pin)
  end

  defp check_for_name(%{"name" => ""}), do: false
  defp check_for_name(_params), do: true

  defp check_for_name_uniquness(%{"name" => name}),
    do: not RotaryEncoder.encoder_exists?(name)

  defp check_for_encoder(%{"encoder_a_pin" => "", "encoder_b_pin" => ""}),
    do: true

  defp check_for_encoder(%{"encoder_a_pin" => ""}),
    do: false

  defp check_for_encoder(%{"encoder_b_pin" => ""}),
    do: false

  defp check_for_encoder(_params),
    do: true

  defp decorate_socket(new_values, socket) do
    Enum.reduce(new_values, socket, fn {k, v} = _app, sckt ->
      assign(sckt, k, v)
    end)
  end

  defp safer_to_integer("") do
    nil
  end

  defp safer_to_integer(item) do
    String.to_integer(item)
  end

  defp empty_or_int?(""), do: true

  defp empty_or_int?(item) do
    case Integer.parse(item) do
      {_int, _rem} ->
        true

      _ ->
        false
    end
  end
end
