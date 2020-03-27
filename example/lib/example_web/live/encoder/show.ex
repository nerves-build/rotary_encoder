defmodule ExampleWeb.Live.Encoder.Show do
  use Phoenix.HTML
  use Phoenix.LiveView
  use Phoenix.Router

  def render(assigns) do
    Phoenix.View.render(ExampleWeb.PageView, "encoder.html", assigns)
  end

  def mount(_params, %{"name" => name}, socket) do
    if connected?(socket), do: RotaryEncoder.subscribe(name)

    {:ok, initialize_socket(socket, name)}
  end

  def handle_info(
        {:travel, %{direction: :ccw, value: value}},
        %{assigns: %{ccw_trigger: ccw_trigger}} = socket
      ) do
    {:noreply, decorate_socket(socket, %{ccw_trigger: ccw_trigger + 1, value: value})}
  end

  def handle_info(
        {:travel, %{direction: :cw, value: value}},
        %{assigns: %{cw_trigger: cw_trigger}} = socket
      ) do
    {:noreply, decorate_socket(socket, %{cw_trigger: cw_trigger + 1, value: value})}
  end

  def handle_info(
        {:click, %{type: :up, duration: duration}},
        %{assigns: %{up_trigger: up_trigger, name: name}} = socket
      ) do
    if duration > 5000 do
      RotaryEncoder.reset_value(name)
    end

    {:noreply,
     decorate_socket(socket, %{up_trigger: up_trigger + 1, duration: "#{duration / 1000}"})}
  end

  def handle_info({:click, %{type: :down}}, %{assigns: %{down_trigger: down_trigger}} = socket) do
    {:noreply, decorate_socket(socket, %{down_trigger: down_trigger + 1})}
  end

  def handle_info(_info, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "simulate_click",
        %{"dir" => "click"},
        %{assigns: %{click_trigger: click_trigger}} = socket
      ) do
    {:noreply, decorate_socket(socket, %{click_trigger: click_trigger + 1})}
  end

  def handle_event("delete_encoder", %{"name" => name}, socket) do
    RotaryEncoder.delete_encoder(name)
    {:noreply, decorate_socket(socket, %{})}
  end

  def handle_event(_msg, _value, socket) do
    {:noreply, decorate_socket(socket, %{})}
  end

  defp initialize_socket(socket, name) do
    socket
    |> assign(name: name)
    |> assign(device: RotaryEncoder.get_state(name))
    |> assign(duration: "up")
    |> assign(value: 0)
    |> assign(cw_trigger: 0)
    |> assign(ccw_trigger: 0)
    |> assign(up_trigger: 0)
    |> assign(down_trigger: 0)
  end

  defp decorate_socket(socket, new_values) do
    Enum.reduce(new_values, socket, fn {k, v} = _app, sckt ->
      Phoenix.LiveView.assign(sckt, k, v)
    end)
  end
end
