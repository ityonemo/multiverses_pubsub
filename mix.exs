defmodule MultiversesPubsub.MixProject do
  use Mix.Project

  @phoenix_pubsub_version "2.0.0"

  def project do
    [
      app: :multiverses_pubsub,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # parent library that's being cloned
      {:phoenix_pubsub, "~> #{@phoenix_pubsub_version}"},
      {:multiverses, "~> 0.4.1", runtime: false},
    ]
  end
end
