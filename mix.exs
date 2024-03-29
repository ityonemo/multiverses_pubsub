defmodule MultiversesPubsub.MixProject do
  use Mix.Project

  @multiverses_version "0.11.0"
  @phoenix_pubsub_version "2.1"

  def project do
    [
      app: :multiverses_pubsub,
      version: "0.6.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "multiverse support for Phoenix.PubSub Library",
        licenses: ["MIT"],
        files: ~w(lib mix.exs README* LICENSE* VERSIONS*),
        links: %{"GitHub" => "https://github.com/ityonemo/multiverses_pubsub"}
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        main: "Multiverses.PubSub",
        extras: ["README.md"],
        source_url: "https://github.com/ityonemo/multiverses_pubsub"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # parent library that's being cloned
      {:phoenix_pubsub, "~> #{@phoenix_pubsub_version}"},
      {:multiverses, "~> #{@multiverses_version}"},
      {:phoenix, "~> 1.6", optional: Mix.env() == :prod},

      # for testing and support
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false}
    ]
  end
end
