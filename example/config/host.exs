use Mix.Config

config :rotary_encoder, RotaryEncoder, gpio_handler: RotaryEncoder.MockGpioPin

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      encoder_a_pin: 1,
      encoder_b_pin: 2,
      button_pin: 3,
      name: "primary"
    },
    %{
      encoder_a_pin: 4,
      encoder_b_pin: 5,
      name: "encoder"
    },
    %{
      encoder_b_pin: 5,
      button_pin: 6,
      btn_default_state: :button_unobserved,
      name: "error"
    },
    %{
      button_pin: 7,
      name: "button"
    }
  ]
