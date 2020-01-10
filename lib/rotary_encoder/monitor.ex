defmodule RotaryEncoder.Monitor do
  defmodule State do
    defstruct last_direction: :neutral,
              a: :low,
              b: :low,
              value: 0,
              last_btn_down: nil
  end

  use GenServer

  alias RotaryEncoder.Monitor

  require Logger

  @target Mix.target()
  @interval 10

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def set_high(name),
    do: GenServer.call(__MODULE__, {:set_pin, :high, name})

  def set_low(name),
    do: GenServer.call(__MODULE__, {:set_pin, :low, name})

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_pin, :high, :switch_gpio}, _from, state) do
    new_state = %{state | last_btn_down: :os.time(:milliseonds)}

    {:reply, new_state, new_state}
  end

  def handle_call({:set_pin, :low, :switch_gpio}, _from, %{last_btn_down: last_btn_down} = state) do
    if :os.time(:milliseonds) - last_btn_down > 5000 do
      click(:long)
    else
      click(:short)
    end

    {:reply, state, state}
  end

  def handle_call(
        {:set_pin, :high, :encoder_a_gpio},
        _from,
        %{a: :low, b: :low, value: value} = state
      ) do
    new_state = %{state | a: :high, value: value - 1}
    broadcast(:ccw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :high, :encoder_a_gpio},
        _from,
        %{a: :low, b: :high, value: value} = state
      ) do
    new_state = %{state | a: :high, value: value + 1}
    broadcast(:cw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :high, :encoder_b_gpio},
        _from,
        %{a: :low, b: :low, value: value} = state
      ) do
    new_state = %{state | b: :high, value: value + 1}
    broadcast(:cw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :high, :encoder_b_gpio},
        _from,
        %{a: :high, b: :low, value: value} = state
      ) do
    new_state = %{state | b: :high, value: value - 1}
    broadcast(:ccw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :low, :encoder_a_gpio},
        _from,
        %{a: :high, b: :low, value: value} = state
      ) do
    new_state = %{state | a: :low, value: value + 1}
    broadcast(:cw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :low, :encoder_a_gpio},
        _from,
        %{a: :high, b: :high, value: value} = state
      ) do
    new_state = %{state | a: :low, value: value - 1}
    broadcast(:ccw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :low, :encoder_b_gpio},
        _from,
        %{a: :low, b: :high, value: value} = state
      ) do
    new_state = %{state | b: :low, value: value - 1}
    broadcast(:ccw)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:set_pin, :low, :encoder_b_gpio},
        _from,
        %{a: :high, b: :high, value: value} = state
      ) do
    new_state = %{state | b: :low, value: value + 1}
    broadcast(:cw)

    {:reply, new_state, new_state}
  end

  def handle_call({:set_pin, _, _}, _from, state) do
    {:reply, state, state}
  end

  def terminate(reason, _state) do
    Logger.error("exiting RuntimeConfig.State due to #{inspect(reason)}")
  end

  defp broadcast(dir) do
    Registry.dispatch(RotaryEncoder, "travel", fn entries ->
      for {pid, _} <- entries do
        send(pid, {:travel, direction: dir})
      end
    end)
  end

  defp click(type \\ :short) do
    Registry.dispatch(RotaryEncoder, "click", fn entries ->
      for {pid, _} <- entries do
        send(pid, {:click, length: type})
      end
    end)
  end
end
