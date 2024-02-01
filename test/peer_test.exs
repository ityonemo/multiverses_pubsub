import MultiversesTest.Replicant

defmoduler MultiversesTest.PeerTest do
  # tests that the pubsub stuff works over a peering connection.
  use ExUnit.Case, async: true

  require Peer

  setup do
    [{{Phoenix.PubSub, _}, shard_id}] = Multiverses.shard(Phoenix.PubSub)
    {:ok, shard_id: shard_id}
  end

  test "a primary can see a pubsub sent from peer", %{shard_id: shard_id} do
    Multiverses.PubSub.subscribe(TestPubSub, "topic")

    _ =
      Peer.call shard_id: shard_id do
        Multiverses.allow(Phoenix.PubSub, shard_id, self())
        Multiverses.PubSub.broadcast(TestPubSub, "topic", :foo)
      end

    assert_receive :foo
  end

  test "a peer can see a pubsub sent from a primary", %{shard_id: shard_id} do
    this = self()

    _ =
      Peer.call shard_id: shard_id, this: this do
        Task.start(fn ->
          Multiverses.allow(Phoenix.PubSub, shard_id, self())
          Multiverses.PubSub.subscribe(TestPubSub, "topic")
          send(this, :unblock)

          receive do
            :foo -> send(this, :done)
          end
        end)
      end

    assert_receive :unblock

    Multiverses.PubSub.broadcast(TestPubSub, "topic", :foo)

    assert_receive :done
  end
end
