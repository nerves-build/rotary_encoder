defmodule ExampleWeb.Live.Encoder.Index do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias ExampleWeb.Live.Encoder

  def render(assigns) do
    ~L"""
    <div class="device_holder">
      <%= for %{name: name} <- @devices do %>
        <%= live_render(@socket, Encoder.Show, session: %{"name" => name}, id: "device_#{name}") %>
      <% end %>
    </div>
    <div class="form_holder">
      <%= live_render(@socket, Encoder.New, session: %{}, id: "enc_form") %>
    </div>
    """
  end

  def mount(_params, %{}, socket) do
    if connected?(socket), do: RotaryEncoder.subscribe("encoder_index")
    {:ok, decorate_socket(socket)}
  end

  def handle_info(:refresh, socket) do
    {:noreply, decorate_socket(socket)}
  end

  defp decorate_socket(sckt) do
    assign(sckt, :devices, RotaryEncoder.all_encoders())
  end
end
