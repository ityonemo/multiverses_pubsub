# parse the guides to obtain the test content
code_examples = __DIR__
|> Path.join("../guides/phoenix.presence.md")
|> File.read!
|> String.split("```")
|> Enum.filter(&String.starts_with?(&1, "elixir"))
|> Enum.map(&String.trim(&1, "elixir"))

# replace the "pubsub module creation example"
code_examples
|> Enum.at(0)
|> String.replace("<my_otp_app>", ":multiverses_pubsub")
|> String.replace("<my_pubsub_server>", "TestPubSub")
|> Code.compile_string

# replace the "presence module creation example"
code_examples
|> Enum.at(1)
|> Code.compile_string

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
