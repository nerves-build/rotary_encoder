defmodule RotaryEncoder.Rotation do
  @moduledoc false

  alias RotaryEncoder.State

  def handle_new_input({:set_pin, pin_state, pin_name}, %State{value: value} = state) do
    case check_for_direction(pin_state, pin_name, state) do
      {:cw, new_state} ->
        {:cw, %State{new_state | value: value + 1}}

      {:ccw, new_state} ->
        {:ccw, %State{new_state | value: value - 1}}

      {_, new_state} ->
        {:none, new_state}
    end
  end

  def check_for_direction(:high, "encoder_a_" <> _name, %State{a: :low, b: :low} = state),
    do: {:ccw, %State{state | a: :high}}

  def check_for_direction(:high, "encoder_a_" <> _name, %State{a: :low, b: :high} = state),
    do: {:cw, %State{state | a: :high}}

  def check_for_direction(:high, "encoder_b_" <> _name, %State{a: :low, b: :low} = state),
    do: {:cw, %State{state | b: :high}}

  def check_for_direction(:high, "encoder_b_" <> _name, %State{a: :high, b: :low} = state),
    do: {:ccw, %State{state | b: :high}}

  def check_for_direction(:low, "encoder_a_" <> _name, %State{a: :high, b: :low} = state),
    do: {:cw, %State{state | a: :low}}

  def check_for_direction(:low, "encoder_a_" <> _name, %State{a: :high, b: :high} = state),
    do: {:ccw, %State{state | a: :low}}

  def check_for_direction(:low, "encoder_b_" <> _name, %State{a: :low, b: :high} = state),
    do: {:ccw, %State{state | b: :low}}

  def check_for_direction(:low, "encoder_b_" <> _name, %State{a: :high, b: :high} = state),
    do: {:cw, %State{state | b: :low}}

  def check_for_direction(_, _, %State{} = state),
    do: {:none, state}
end
