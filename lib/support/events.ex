defmodule RotaryEncoder.Events do
  @moduledoc false

  def simulate_turn(name, dir) do
    RotaryEncoder.Monitor.simulate_turn(name, dir)
  end

  def simulate_click(name, dir) do
    RotaryEncoder.Monitor.simulate_click(name, dir)
  end
end
