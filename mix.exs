defmodule RotaryEncoder.MixProject do
  use Mix.Project

  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :x86_64]

  def project do
    [
      app: :rotary_encoder,
      version: "1.0.0",
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      source_url: "https://github.com/nerves-build/rotary_encoder",
      docs: [
        # The main page in the docs
        main: "RotaryEncoder",
        api_reference: false,
        extra_section: "Guides",
        extras: [
          "README.md"
        ],
        groups_for_extras: [
          Guides: Path.wildcard("README.md")
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RotaryEncoder.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:circuits_gpio, "~> 0.4", targets: @all_targets}
    ]
  end

  defp description do
    """
    Library for using a rotary encoder in Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Steven Fuchs"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nerves-build/rotary_encoder"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
