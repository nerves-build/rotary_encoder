defmodule RotaryEncoder.GpioPin do
  use GenServer

  alias RotaryEncoder.Monitor

  def start_link(%{name: name} = args) do
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @impl true
  def init(%{gpio: gpio_pin, type: type, name: name}) do
    # Button
    {:ok, gpio} = Circuits.GPIO.open(gpio_pin, :input)
    :ok = Circuits.GPIO.set_pull_mode(gpio, type)
    :ok = Circuits.GPIO.set_interrupts(gpio, :both)

    {:ok, %{gpio: gpio, pin: gpio_pin, name: name}}
  end

  @impl true
  def handle_info({:circuits_gpio, _gpio_pin, _timestamp, 1}, %{name: name} = state) do
    Monitor.set_high(name)

    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _gpio_pin, _timestamp, 0}, %{name: name} = state) do
    Monitor.set_low(name)

    {:noreply, state}
  end

  @impl true
  # If you pass a third var in ms, this will happen if no messages are received before that happens
  def handle_info(:timeout, state) do
    {:noreply, state}
  end
end
