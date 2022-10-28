defmodule Peer.PubSub do
  @moduledoc false
  # module to bootstrap a peer pubsub.
  def start_unlinked do
    Task.start(fn ->
      Supervisor.start_link([{Phoenix.PubSub, name: TestPubSub}], strategy: :one_for_one)

      receive do
        :hold -> :open
      end
    end)
  end
end
