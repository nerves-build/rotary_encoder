use Mix.Config

config :rotary_encoder, RotaryEncoder,
  switch_gpio: 13,
  encoder_a_gpio: 17,
  encoder_b_gpio: 18

import_config "#{Mix.env()}.exs"
