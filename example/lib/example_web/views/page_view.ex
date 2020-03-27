defmodule ExampleWeb.PageView do
  use ExampleWeb, :view

  def button_default_state(%{btn_default_state: :button_open}) do
    "normally open"
  end

  def button_default_state(%{btn_default_state: :button_closed}) do
    "normally closed"
  end

  def def_state(%{btn_default_state: :button_closed}) do
    "normally closed"
  end

  def should_draw_encoder?(%{encoder_a_pin: encoder_a_pin, encoder_b_pin: encoder_b_pin})
      when not (is_nil(encoder_a_pin) or is_nil(encoder_b_pin)) do
    true
  end

  def should_draw_encoder?(_device) do
    false
  end

  def draw_encoder(%{encoder_a_pin: nil, encoder_b_pin: nil}) do
    ""
  end

  def draw_encoder(%{encoder_a_pin: encoder_a_pin, encoder_b_pin: encoder_b_pin})
      when is_nil(encoder_a_pin) or is_nil(encoder_b_pin) do
    ~e{<div class="error">Misconfigured Encoder</div>}
  end

  def draw_encoder(%{encoder_a_pin: encoder_a_pin, encoder_b_pin: encoder_b_pin}) do
    ~e{<div>Encoder pins: <%= encoder_a_pin %>,<%= encoder_b_pin %></div>}
  end

  def draw_button(%{button_pin: nil}) do
    ~e{}
  end

  def draw_button(%{button_pin: button_pin, btn_default_state: :button_open}) do
    ~e{Button: Pin <%= button_pin %>, normally open}
  end

  def draw_button(%{button_pin: button_pin, btn_default_state: :button_closed}) do
    ~e{Button: Pin <%= button_pin %>, normally closed}
  end

  def draw_button(%{button_pin: _, btn_default_state: _}) do
    ~e{<div class="error">Misconfigured Button</div>}
  end
end
