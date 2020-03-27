defmodule ExampleWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: ExampleWeb

      import Plug.Conn
      import ExampleWeb.Gettext
      import Phoenix.LiveView.Controller
      alias ExampleWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/example_web/templates",
        namespace: ExampleWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ExampleWeb.ErrorHelpers
      import ExampleWeb.Gettext
      import Phoenix.LiveView.Helpers
      alias ExampleWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ExampleWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
