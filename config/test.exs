use Mix.Config

config :rotary_encoder, :RotaryEncoder, gpio_handler: RotaryEncoder.MockGpioPin

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      button_pin: 13,
      encoder_a_pin: 17,
      encoder_b_pin: 18,
      name: "main"
    }
  ]
