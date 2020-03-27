use Mix.Config

config :rotary_encoder, RotaryEncoder, gpio_handler: RotaryEncoder.GpioPin

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      button_pin: 24,
      encoder_a_pin: 23,
      encoder_b_pin: 22,
      name: "main"
    }
  ]
