defmodule RotaryEncoderTest do
  use ExUnit.Case
  doctest RotaryEncoder

  test "reads the config" do
    assert %{
      encoder_a_gpio: 17,
      encoder_b_gpio: 18,
      switch_gpio: 13
    } = RotaryEncoder.get_state()
  end


end
