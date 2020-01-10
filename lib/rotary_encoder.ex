defmodule RotaryEncoder do
  @moduledoc """
  Documentation for RotaryEncoder.
  """

  alias RotaryEncoder.LedString
  alias RotaryEncoder.Monitor

  def get_state do
    Monitor.get_state()
  end

  def set_value(new_val) do
    LedString.set_value(new_val)
  end

end
