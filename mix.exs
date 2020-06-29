defmodule MultiversesPubsub.MixProject do
  use Mix.Project

  @phoenix_pubsub_version "2.0.0"

  def project do
    [
      app: :multiverses_pubsub,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "multiverse support for Phoenix.PubSub Library",
        licenses: ["MIT"],
        files: ~w(lib mix.exs README* LICENSE* VERSIONS*),
        links: %{"GitHub" => "https://github.com/ityonemo/multiverses_pubsub"}
      ],
      docs: [
        main: "Multiverses.Phoenix.PubSub",
        extra_section: "GUIDES",
        groups_for_extras: ["Guides": ~r/guides\/.?/],
        extras: ["README.md", "guides/phoenix.presence.md"],
        source_url: "https://github.com/ityonemo/multiverses_pubsub"
      ],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # parent library that's being cloned
      {:phoenix_pubsub, "~> #{@phoenix_pubsub_version}"},
      {:multiverses, "~> 0.5.0"},

      # for testing and support
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.1", only: :dev, runtime: false}
    ]
  end
end
