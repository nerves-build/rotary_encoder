defmodule RotaryEncoder.State do
  @moduledoc """
  This holds all state information for a given encoder.

  | Name | Description |
  | ---: | --- |
  | name | The given name of the encoder |
  | encoder_a_pin | The "A" pin number for the rotary encoder |
  | encoder_b_pin| The "B" pin number for the rotary encoder |
  | button_pin | The pin representing the dial button |
  | btn_default_state | Set when beginning monitoring of an encoder. This value depends on the wiring of your encoder |
  | value | The value for the encoder, cumulative steps since startup or being reset. Useful for the client but available directly through `RotaryRncoder.get_value/1` |
  | last_direction | The last movement registered by the rotary encoder. Defaults to :neutral and can also be :ccw and :cw |
  | pid | The pid of the encoder process. *Usually not needed by client projects* |
  | a | The state of the A pin. *Usually not needed by client projects* |
  | b | The state of the B pin. *Usually not needed by client projects* |
  | last_btn_event | Used internally to determine click duration. *Usually not needed by client projects* |
  | attached | Used internally to determine encoder validity. *Usually not needed by client projects* |

  """
  defstruct last_direction: :neutral,
            attached: false,
            encoder_a_pin: nil,
            encoder_b_pin: nil,
            button_pin: nil,
            name: nil,
            pid: nil,
            a: :low,
            b: :low,
            value: 0,
            last_btn_event: 0,
            btn_default_state: :button_open
end
