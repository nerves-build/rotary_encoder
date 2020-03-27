defmodule RotaryEncoder.Monitor do
  @moduledoc false

  use GenServer

  alias RotaryEncoder.Dispatcher
  alias RotaryEncoder.GpioPin
  alias RotaryEncoder.Monitor
  alias RotaryEncoder.Rotation
  alias RotaryEncoder.State

  require Logger

  @settable_fields ~w(encoder_a_pin encoder_b_pin button_pin name btn_default_state)a

  def monitor_encoder(%{name: name} = params) do
    case find_named_monitor(name) do
      nil ->
        DynamicSupervisor.start_child(
          RotaryEncoder.DynamicSupervisor,
          {Monitor, params}
        )

      _ ->
        {:error, "encoder #{inspect(name)} already exists"}
    end
  end

  def find_named_monitor(name) do
    Process.whereis(monitor_name(name))
  end

  def start_link(opts) do
    %State{name: name} = state = build_state(opts)
    GenServer.start_link(__MODULE__, state, name: monitor_name(name))
  end

  def reset_value(name),
    do: GenServer.call(monitor_name(name), :reset_value)

  def get_state(name) when is_binary(name),
    do: GenServer.call(monitor_name(name), :get_state)

  def get_state(name) when is_pid(name),
    do: GenServer.call(name, :get_state)

  def simulate_turn(name, dir),
    do: GenServer.call(monitor_name(name), {:simulate_turn, dir})

  def simulate_click(name, dir),
    do: GenServer.call(monitor_name(name), {:simulate_click, dir})

  def set_high(name),
    do: GenServer.call(monitor_name(name), {:set_pin, :high, name})

  def set_low(name),
    do: GenServer.call(monitor_name(name), {:set_pin, :low, name})

  def init(state) do
    state
    |> setup_pins()
    |> attach_process()
    |> case do
      %State{pid: nil} ->
        {:error, :failed}

      new_state ->
        Process.flag(:trap_exit, true)
        Dispatcher.broadcast_update(new_state)
        {:ok, new_state}
    end
  end

  def handle_call(:get_state, _from, state),
    do: {:reply, state, state}

  def handle_call(:reset_value, _from, state),
    do: {:reply, 0, %{state | value: 0}}

  def handle_call(
        {:set_pin, :low, "button_" <> _},
        _from,
        %State{btn_default_state: :button_closed} = state
      ) do
    state = handle_click(:down, state)

    {:reply, state, state}
  end

  def handle_call(
        {:set_pin, :high, "button_" <> _},
        _from,
        %State{btn_default_state: :button_open} = state
      ) do
    state = handle_click(:down, state)
    {:reply, state, state}
  end

  def handle_call({:set_pin, _level, "button_" <> _}, _from, %State{} = state) do
    state = handle_click(:up, state)
    {:reply, state, state}
  end

  def handle_call({:simulate_click, dir}, _from, %State{} = state) do
    state = handle_click(dir, state)
    {:reply, state, state}
  end

  def handle_call({:set_pin, _, "encoder_" <> _} = input, _from, state) do
    {dir, new_state} = Rotation.handle_new_input(input, state)
    Dispatcher.broadcast_turn(new_state, dir)
    {:reply, new_state, new_state}
  end

  def handle_call({:simulate_turn, :ccw}, _from, %State{value: value} = state) do
    state = Dispatcher.broadcast_turn(%State{state | value: value - 1}, :ccw)
    {:reply, state, state}
  end

  def handle_call({:simulate_turn, :cw}, _from, %State{value: value} = state) do
    state = Dispatcher.broadcast_turn(%State{state | value: value + 1}, :cw)
    {:reply, state, state}
  end

  defp handle_click(dir, %State{} = state) do
    state
    |> Dispatcher.broadcast_click(dir)
    |> attach_btn_time()
  end

  def terminate(_reason, state) do
    Dispatcher.broadcast_update(state)
  end

  defp setup_pins(state), do: GpioPin.setup_pins(state)

  defp monitor_name(nil), do: raise(ArgumentError)

  defp monitor_name("encoder_a_" <> name), do: monitor_name(name)
  defp monitor_name("encoder_b_" <> name), do: monitor_name(name)
  defp monitor_name("button_" <> name), do: monitor_name(name)

  defp monitor_name(name),
    do: String.to_atom(name <> "_monitor")

  defp attach_process(%State{attached: false} = state),
    do: state

  defp attach_process(%State{} = state),
    do: %{state | pid: self()}

  defp attach_btn_time(%State{} = state),
    do: %State{state | last_btn_event: :os.system_time(:millisecond)}

  defp build_state(opts) do
    opts = Map.take(opts, @settable_fields)
    struct(%State{}, opts)
  end
end
