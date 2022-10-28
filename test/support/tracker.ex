defmodule MultiverseTest.Tracker do
  use Phoenix.Tracker

  @phoenix_tracker Multiverses.Tracker
  @pubsub Multiverses.PubSub

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    @phoenix_tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def handle_diff(diff, state) do
    for {topic, {joins, leaves}} <- diff do
      for {_key, meta} <- joins do
        @pubsub.broadcast(TestPubSub, "joined", {:joined, topic, meta.pid})
      end

      for {_key, meta} <- leaves do
        @pubsub.broadcast(TestPubSub, "left", {:left, topic, meta.pid})
      end
    end

    {:ok, state}
  end
end
