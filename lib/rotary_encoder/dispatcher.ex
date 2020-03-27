defmodule RotaryEncoder.Dispatcher do
  @moduledoc false

  alias RotaryEncoder.State

  def subscribe(name) do
    {:ok, _pid} = Registry.register(RotaryEncoder, name, [])
  end

  @spec broadcast_click(RotaryEncoder.State.t(), :down | :up) :: RotaryEncoder.State.t()
  def broadcast_update(state) do
    do_send_data("encoder_index", :refresh)
    state
  end

  def broadcast_click(%State{name: name} = state, :down) do
    do_send_data(name, {:click, %{type: :down}})
    state
  end

  def broadcast_click(%State{name: name, last_btn_event: last_btn_event} = state, :up) do
    click_duration = :os.system_time(:millisecond) - last_btn_event
    do_send_data(name, {:click, %{type: :up, duration: click_duration}})
    state
  end

  def broadcast_turn(%{name: name, value: value} = state, dir) do
    case dir do
      :ccw ->
        do_send_data(name, {:travel, %{direction: :ccw, value: value}})

      :cw ->
        do_send_data(name, {:travel, %{direction: :cw, value: value}})

      _ ->
        :ok
    end

    state
  end

  defp do_send_data(name, data) do
    Registry.dispatch(RotaryEncoder, name, fn entries ->
      for {pid, _} <- entries do
        send(pid, data)
      end
    end)
  end
end
