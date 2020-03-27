defmodule RotaryEncoder do
  @moduledoc """
  Documentation for RotaryEncoder, a library for using rotary encoders in Elixir.

  Encoders can be set up via the config or can be programatically added and deleted at runtime.
  ```
  config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      name: "main"
      encoder_a_pin: 22,
      encoder_b_pin: 23,
      button_pin: 24,
    }
  ]

  # or

  RotaryEncoder.add_encoder("main", 22, 23, 24)

  # and

  RotaryEncoder.delete_encoder("main")

  ```
  Then inside your code just subscribe to that encoder in whatever process need the notification and wait to receive events.

  ```
  def init(opts) do
    RotaryEncoder.subscribe(main)
  end

  def handle_info({:travel, %{direction: :ccw, value: value}}, socket) do
    # react to counter-clockwise rotation
    {:noreply, socket}
  end

  def handle_info({:travel, %{direction: :cw, value: value}}, socket) do
    # react to clockwise rotation
    {:noreply, socket}
  end

  def handle_info({:click, %{type: :up, duration: duration}}, socket) do
    # react to button up
    {:noreply, socket}
  end

  def handle_info({:click, %{type: :down}}, socket) do
    # react to button down
    {:noreply, socket}
  end
  ```
  """
  alias RotaryEncoder.Dispatcher
  alias RotaryEncoder.Monitor

  @doc """
    Returns a `RotaryEncoder.State` struct describing the named encoder.

    Will raise if the encoder does not exist.
  """
  def get_state(name) do
    Monitor.get_state(name)
  end

  @doc """
    Returns the value of the named encoder. The value is initiated at zero and incermertned or decremented every time the encoder is turned.

    Will raise if the encoder does not exist.
  """
  def get_value(name) do
    %{value: value} = Monitor.get_state(name)
    value
  end

  @doc """
    Will reset the value of the named encoder to 0.

    Will raise if the encoder does not exist.
  """
  def reset_value(name) do
    Monitor.reset_value(name)
  end

  @doc """
    Returns an array `RotaryEncoder.State` structs representing all encoders.
  """
  def all_encoders do
    for {_, pid, _, [RotaryEncoder.Monitor]} <- get_encoders() do
      RotaryEncoder.Monitor.get_state(pid)
    end
  end

  @doc """
    Begin monitoring the specified encoder pins.
    The name parameter is required and it must not already be in use.

    In order for the encoder portion to work both encoder_a_pin and encoder_b_pin parameters must be set.
    In order for the push button portion (if there is one) the button_pin parameter must be set.

    Neither of these options are necessary, the library can monitor a single button, or a rotary encoder without a push button built in. Use nil for paramters you don't want to use.
  """
  def add_encoder(name, encoder_a_pin, encoder_b_pin, button_pin) do
    Monitor.monitor_encoder(%{
      name: name,
      encoder_a_pin: encoder_a_pin,
      encoder_b_pin: encoder_b_pin,
      button_pin: button_pin
    })
  end

  @doc """
  Stop monitoring the pins associated with the named encoder.
  """
  def delete_encoder(name) do
    %{pid: pid} = Monitor.get_state(name)
    DynamicSupervisor.terminate_child(RotaryEncoder.DynamicSupervisor, pid)
  end

  @doc """
  Returns true if an encoder with the given name already exists.
  """
  def encoder_exists?(name) do
    RotaryEncoder.Monitor.find_named_monitor(name) != nil
  end

  @doc """
  Start listening for the named encoders events in the calling thread.
  """
  def subscribe(name) do
    {:ok, _pid} = Dispatcher.subscribe(name)
  end

  defp get_encoders do
    DynamicSupervisor.which_children(RotaryEncoder.DynamicSupervisor)
  end
end
