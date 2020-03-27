use Mix.Config

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      encoder_a_pin: 24,
      encoder_b_pin: 25,
      button_pin: 23,
      btn_default_state: :button_closed,
      name: "primary"
    }
  ]
