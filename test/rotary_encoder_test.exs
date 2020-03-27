defmodule RotaryEncoderTest do
  use ExUnit.Case
  doctest RotaryEncoder

  setup do
    start_supervised!(%{
      id: RotaryEncoder.Application,
      start: {RotaryEncoder.Application, :start, [:app, []]}
    })

    :ok
  end

  test "reads the config" do
    assert %{
             encoder_a_pin: 17,
             encoder_b_pin: 18,
             button_pin: 13
           } = RotaryEncoder.get_state("main")
  end

  test "can add an encoder" do
    RotaryEncoder.add_encoder("added", 1, 2, 3)

    assert %{
             encoder_a_pin: 1,
             encoder_b_pin: 2,
             button_pin: 3
           } = RotaryEncoder.get_state("added")
  end

  test "can add a button without an encoder" do
    RotaryEncoder.add_encoder("added", nil, nil, 3)

    assert %{
             button_pin: 3
           } = RotaryEncoder.get_state("added")
  end

  test "can add an encoder without button" do
    RotaryEncoder.add_encoder("added", 1, 2, nil)

    assert %{
             encoder_a_pin: 1,
             encoder_b_pin: 2
           } = RotaryEncoder.get_state("added")
  end

  test "can add an encoder with only one pin" do
    RotaryEncoder.delete_encoder("main")
    RotaryEncoder.add_encoder("added", 14, nil, nil)

    assert RotaryEncoder.all_encoders() == []
  end

  test "can not add an encoder with a duplicate name" do
    {:error, _pid} = RotaryEncoder.add_encoder("main", 14, nil, nil)

    assert Enum.count(RotaryEncoder.all_encoders()) == 1
  end

  test "can not add an encoder without any pins" do
    RotaryEncoder.delete_encoder("main")
    RotaryEncoder.add_encoder("added", nil, nil, nil)

    assert RotaryEncoder.all_encoders() == []
  end

  test "can not add an encoder bad data" do
    RotaryEncoder.delete_encoder("main")
    RotaryEncoder.add_encoder("added", :dog, :cat, "me")

    assert RotaryEncoder.all_encoders() == []
  end

  test "can delete an encoder" do
    RotaryEncoder.delete_encoder("main")

    assert RotaryEncoder.all_encoders() == []
  end

  test "can subscribe to an encoder" do
    spawn(fn ->
      RotaryEncoder.subscribe("main")

      data =
        receive do
          data ->
            data
        after
          10 ->
            nil
        end

      assert data == {:travel, %{direction: :cw, value: 1}}
    end)

    RotaryEncoder.Events.simulate_turn("main", :cw)
    Process.sleep(20)
  end
end
