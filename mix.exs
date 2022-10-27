defmodule MultiversesPubsub.MixProject do
  use Mix.Project

  @multiverses_version "0.8.0"
  @phoenix_pubsub_version "2.1.0"

  def project do
    [
      app: :multiverses_pubsub,
      version: "0.4.0",
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
        groups_for_extras: [Guides: ~r/guides\/.?/],
        extras: ["README.md", "guides/phoenix.presence.md"],
        source_url: "https://github.com/ityonemo/multiverses_pubsub"
      ]
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
      #{:multiverses, "~> #{@multiverses_version}"},
      {:multiverses, path: "../multiverses"},

      # for testing and support
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false}
    ]
  end
end
