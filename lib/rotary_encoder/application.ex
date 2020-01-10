defmodule RotaryEncoder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    opts = Application.get_env(:rotary_encoder, RotaryEncoder, [])

    children =
      [
        {Registry, keys: :duplicate, name: RotaryEncoder},
        RotaryEncoder.Monitor,
        build_child(args, :switch_gpio, :pulldown),
        build_child(args, :encoder_a_gpio, :pullup),
        build_child(args, :encoder_b_gpio, :pullup)
      ]
      |> Enum.filter(&(!is_nil(&1)))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RotaryEncoder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def build_child(opts, type, name) do
    case get_pin(opts, name) do
      nil ->
        nil

      pin ->
        Supervisor.child_spec(
          {RotaryEncoder.GpioPin, %{pin: pin, type: type, name: name}, id: name},
          id: name
        )
    end
  end

  def get_pin(opts, name) do
    case Keyword.get(opts, name) do
      nil ->
        opts = Application.get_env(:rotary_encoder, RotaryEncoder, [])
        Keyword.get(opts, name)

      value ->
        value
    end
  end
end
