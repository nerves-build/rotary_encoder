# RotaryEncoder

This package will add support for rotary encoders to your elixir project.

Rotary encoders are a common solution when you want directional input but don't require absolute location. In other words a knob that tells you when been turned to the right or left, but can't tell you exactly where it's currently pointing.
Many rotary encoders also support pressing the knob as an alternate form of input and are supported by this library.

This library does support a resetable value field, which defaults to 0 at startup but will not retain positioning between runs. 

## Installation

```elixir
def deps do
  [
    {:rotary_encoder, "~> 1.0.0"}
  ]
end
```

## Usage
  Encoders can be set up via the config or can be programatically added and deleted at runtime. In order to set up an encoder wired like this would need the code shown below.
  ![wiring](/example/assets/static/images/rotary_encoder_bb.png)

  ```elixir
  config :rotary_encoder, RotaryEncoder,
    gpio_handler: RotaryEncoder.GpioPin,
    encoders: [
      %{
        name: "main"
        encoder_a_pin: 22,
        encoder_b_pin: 23,
        button_pin: 24,
      }
    ]

  # or

  RotaryEncoder.add_encoder("main", 22, 23, 24)

  # and

  RotaryEncoder.delete_encoder("main")

  ```
Note the additional config keyword :gpio_handler.  This will let you swap out the actual hardware interface with stub library that does nothing (`RotaryEncoder.MockGpioPin`). This will let you run your app in a laptop environment where no GPIO pins are available.
The default is `RotaryEncoder.GpioPin`.

  
  Then inside your code just subscribe to that encoder in whatever process need the notification and wait to receive events. The example app does this inside the mount call to its LiveView process.

  ```elixir
  def mount(_params, %{"name" => name, "parent" => parent}, socket) do
    if connected?(socket), do: RotaryEncoder.subscribe(name)

    {:ok, initialize_socket(socket, name, parent)}
  end

  def handle_info({:travel, %{direction: :ccw, value: value}}, socket) do
    # react to counter-clockwise rotation
    {:noreply, socket}
  end

  def handle_info({:travel, %{direction: :cw, value: value}}, socket) do
    # react to clockwise rotation
    {:noreply, socket}
  end

  def handle_info({:click, %{type: :up, duration: duration}}, socket) do
    # react to button up
    {:noreply, socket}
  end

  def handle_info({:click, %{type: :down}}, socket) do
    # react to button down
    {:noreply, socket}
  end
```

## Example App
There is an example application located in /example. In order to run this execute app you should clone this repository onto your device (in this case an RPI0W) with the rotary encoder wired up. Adjust the values in target.exs to reflect your wired up pins.

```bash
export MIX_TARGET=rpi0 # or whatever device you are deploying on
cd rotary_encoder/example
mix deps.get
npm install --prefix=assets
mix phx.server
```


## Example App in host mode
The example app will run in host mode on a laptop, but there isn't much opportunity to see it work. If you start the app using `iex -S mix phx.server` however you can stimulate some events manually

```bash
iex -S mix phx.server
iex(1)> RotaryEncoder.Events.simulate_turn("primary", :ccw)
iex(1)> RotaryEncoder.Events.simulate_turn("primary", :cw)

iex(2)> RotaryEncoder.Events.simulate_click("primary", :down)
iex(2)> RotaryEncoder.Events.simulate_click("primary", :up)

```





