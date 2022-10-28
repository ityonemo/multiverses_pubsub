import MultiversesTest.Replicant

defmoduler MultiverseTest.TrackerTest do
  use ExUnit.Case, async: true

  @pubsub Multiverses.PubSub
  @tracker Multiverses.Tracker

  setup do
    Multiverses.shard(PubSub)
    :ok
  end

  describe "tracker function" do
    test "track/4" do
      this = self()
      @pubsub.subscribe(TestPubSub, "joined")
      @tracker.track(TestTracker, self(), "topic", "base", %{pid: this})
      assert_receive {:joined, "topic", ^this}
    end

    test "untrack/4" do
      this = self()
      @tracker.track(TestTracker, self(), "topic", "base", %{pid: this})
      @pubsub.subscribe(TestPubSub, "left")
      @tracker.untrack(TestTracker, self(), "topic", "base")
      assert_receive {:left, "topic", ^this}
    end

    test "update/5" do
      this = self()
      @tracker.track(TestTracker, self(), "topic", "base", %{pid: this})
      @pubsub.subscribe(TestPubSub, "left")
      @pubsub.subscribe(TestPubSub, "joined")

      @tracker.update(TestTracker, self(), "topic", "base", %{pid: this, state: "extra"})

      assert_receive {:joined, "topic", ^this}
      assert_receive {:left, "topic", ^this}
    end

    test "get_by_key/3" do
      this = self()
      @tracker.track(TestTracker, self(), "topic", "base", %{pid: this})

      assert [{^this, %{pid: ^this}}] = @tracker.get_by_key(TestTracker, "topic", "base")
    end

    test "list/2" do
      this = self()
      @tracker.track(TestTracker, self(), "topic", "base", %{pid: this})
      assert [{"base", %{pid: ^this}}] = @tracker.list(TestTracker, "topic")
    end
  end
end
