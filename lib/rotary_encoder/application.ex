defmodule RotaryEncoder.Application do
  @moduledoc false

  use Application
  require Logger
  alias RotaryEncoder.Monitor

  def start(_type, _args) do
    prefs = Application.get_env(:rotary_encoder, RotaryEncoder, [])
    encoders = Keyword.get(prefs, :encoders, [])

    children = [
      {Registry, keys: :duplicate, name: RotaryEncoder},
      {DynamicSupervisor, strategy: :one_for_one, name: RotaryEncoder.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: RotaryEncoder.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    for encoder <- encoders do
      Monitor.monitor_encoder(encoder)
    end

    {:ok, pid}
  end
end
