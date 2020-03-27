defmodule RotaryEncoder.GpioPin do
  @moduledoc false
  use GenServer

  require Logger

  alias RotaryEncoder.Monitor
  alias RotaryEncoder.State

  def start_link(%{name: name} = args) do
    GenServer.start_link(__MODULE__, args, name: String.to_atom(name))
  end

  defguard non_empty_int?(item) when is_integer(item) and item != 0

  def setup_pins(%State{button_pin: button_pin, name: name} = state)
      when non_empty_int?(button_pin) do
    setup_pin(button_pin, :pulldown, "button_" <> name)
    setup_pins(%{state | button_pin: nil})
    %{state | attached: true}
  end

  def setup_pins(
        %State{encoder_a_pin: encoder_a_pin, encoder_b_pin: encoder_b_pin, name: name} = state
      )
      when non_empty_int?(encoder_a_pin) and non_empty_int?(encoder_b_pin) do
    setup_pin(encoder_a_pin, :pullup, "encoder_a_" <> name)
    setup_pin(encoder_b_pin, :pullup, "encoder_b_" <> name)
    %{state | attached: true}
  end

  def setup_pins(state), do: state

  defp setup_pin(pin_num, type, name) do
    start_link(%{name: name, pin: pin_num, type: type})
  end

  @impl true
  def init(%{pin: gpio_pin, type: type, name: name}) do
    gpio_handler =
      Application.get_env(:rotary_encoder, RotaryEncoder, [])
      |> Keyword.get(:gpio_handler, Circuits.GPIO)

    case gpio_handler.open(gpio_pin, :input) do
      {:ok, gpio} ->
        :ok = gpio_handler.set_pull_mode(gpio, type)
        :ok = gpio_handler.set_interrupts(gpio, :both)
        {:ok, %{gpio: gpio, pin: gpio_pin, name: name}}

      error ->
        Logger.error("Error opening gpio pin #{gpio_pin} - #{inspect(error)}")
        {:ok, %{gpio: nil, pin: gpio_pin, name: name}}
    end
  end

  @impl true
  def handle_info({:circuits_gpio, _gpio, _ts, 1}, %{name: name} = state) do
    Monitor.set_high(name)
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _gpio, _ts, 0}, %{name: name} = state) do
    Monitor.set_low(name)
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:noreply, state}
  end
end
