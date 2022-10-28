defmodule MultiversesTest.Presence do
  use Phoenix.Presence,
    otp_app: :multiverses_pubsub,
    pubsub_server: TestPubSub
end

require Multiverses.Presence
Multiverses.Presence.clone(MultiversesTest.Presence, as: MultiversesTest.Multiverses.Presence)

import MultiversesTest.Replicant

defmoduler MultiversesTest.PresenceTest do
  use ExUnit.Case, async: true

  @pub_sub Multiverses.PubSub
  @presence MultiversesTest.Multiverses.Presence

  setup_all do
    Supervisor.start_link([MultiversesTest.Presence], strategy: :one_for_one)
    :ok
  end

  setup do
    Multiverses.shard(PubSub)
    :ok
  end

  test "basic presence guidelines work" do
    @pub_sub.subscribe(TestPubSub, "test")

    @presence.track(self(), "test", "foo", %{})

    assert_receive %{
      event: "presence_diff",
      payload: %{joins: %{"foo" => _}},
      topic: "test" <> _
    }

    @presence.untrack(self(), "test", "foo")

    assert_receive %{
      event: "presence_diff",
      payload: %{leaves: %{"foo" => _}},
      topic: "test" <> _
    }
  end

  test "multiverse segregation is achieved" do
    test_pid = self()
    @pub_sub.subscribe(TestPubSub, "test")

    spawn_link(fn ->
      Multiverses.shard(PubSub)
      @pub_sub.subscribe(TestPubSub, "test")

      send(test_pid, :synchronize)

      @presence.track(self(), "test", "bar", %{})

      assert_receive %{payload: %{joins: %{"bar" => _}}}
      refute_receive %{payload: %{joins: %{"foo" => _}}}

      send(test_pid, :done)

      receive do
        :hold -> :forever
      end
    end)

    assert_receive :synchronize

    @presence.track(self(), "test", "foo", %{})

    assert_receive %{payload: %{joins: %{"foo" => _}}}
    refute_receive %{payload: %{joins: %{"bar" => _}}}

    assert_receive :done
  end
end
