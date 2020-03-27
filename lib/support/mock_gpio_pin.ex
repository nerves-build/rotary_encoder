defmodule RotaryEncoder.MockGpioPin do
  @moduledoc false
  @spec open(any, any) :: {:ok, any}
  def open(gpio_pin, _type) do
    {:ok, gpio_pin}
  end

  def set_pull_mode(_gpio, _type) do
    :ok
  end

  def set_interrupts(_gpio, _type) do
    :ok
  end
end
