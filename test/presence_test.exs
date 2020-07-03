defmodule MyApp.Presence do
  use Phoenix.Presence, otp_app: :multiverses_pubsub,
                        pubsub_server: TestPubSub
end

defmodule Multiverses.MyApp.Presence do
  use Multiverses.MacroClone,
    module: MyApp.Presence,
    except: [
      fetch: 2, get_by_key: 2, list: 1,
      track: 4, untrack: 3, update: 4
    ]

  defclone fetch(topic, presences) do
    if is_binary(topic) do
      MyApp.Presence.fetch(Multiverses.Phoenix.PubSub.universal(topic), presences)
    else
      # channel
      MyApp.Presence.fetch(topic, presences)
    end
  end

  defclone get_by_key(topic, presences) do
    if is_binary(topic) do
      MyApp.Presence.get_by_key(Multiverses.Phoenix.PubSub.universal(topic), presences)
    else
      # channel
      MyApp.Presence.get_by_key(topic, presences)
    end
  end

  defclone list(topic) do
    if is_binary(topic) do
      MyApp.Presence.list(Multiverses.Phoenix.PubSub.universal(topic))
    else
      # channel
      MyApp.Presence.list(topic)
    end
  end

  defclone track(pid, topic, key, meta) do
    MyApp.Presence.track(pid, Multiverses.Phoenix.PubSub.universal(topic), key, meta)
  end

  defclone untrack(pid, topic, key) do
    MyApp.Presence.untrack(pid, Multiverses.Phoenix.PubSub.universal(topic), key)
  end

  defclone update(pid, topic, key, meta) do
    MyApp.Presence.update(pid, Multiverses.Phoenix.PubSub.universal(topic), key, meta)
  end
end

import MultiversesTest.Replicant
defmoduler MultiversesTest.PresenceTest do
  use ExUnit.Case, async: true

  use Multiverses, with: [Phoenix.PubSub, MyApp.Presence]

  setup_all do
    Supervisor.start_link([MyApp.Presence], strategy: :one_for_one)
    :ok
  end

  test "basic presence guidelines work" do
    PubSub.subscribe(TestPubSub, "test")

    Presence.track(self(), "test", "foo", %{})

    assert_receive %{
      event: "presence_diff",
      payload: %{joins: %{"foo" => _}},
      topic: "test" <> _
    }

    Presence.untrack(self(), "test", "foo")

    assert_receive %{
      event: "presence_diff",
      payload: %{leaves: %{"foo" => _}},
      topic: "test" <> _
    }
  end

  test "multiverse segregation is achieved" do
    test_pid = self()
    PubSub.subscribe(TestPubSub, "test")

    spawn_link fn ->
      PubSub.subscribe(TestPubSub, "test")

      send(test_pid, :synchronize)

      Presence.track(self(), "test", "bar", %{})

      assert_receive %{payload: %{joins: %{"bar" => _}}}
      refute_receive %{payload: %{joins: %{"foo" => _}}}

      send(test_pid, :done)
      receive do :hold -> :forever end
    end

    assert_receive :synchronize

    Presence.track(self(), "test", "foo", %{})

    assert_receive %{payload: %{joins: %{"foo" => _}}}
    refute_receive %{payload: %{joins: %{"bar" => _}}}

    assert_receive :done
  end

end
