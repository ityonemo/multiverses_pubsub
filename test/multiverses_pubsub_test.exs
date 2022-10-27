import MultiversesTest.Replicant

defmoduler Multiverses.PubSubTest do
  use ExUnit.Case, async: true

  @pub_sub Multiverses.PubSub

  setup do
    Multiverses.shard(PubSub)
  end

  def run_same_universe(dispatch) do
    test_pid = self()

    Task.async(fn ->
      @pub_sub.subscribe(TestPubSub, "topic")
      send(test_pid, :unlock)

      assert_receive :foo

      send(test_pid, :done)
    end)

    receive do
      :unlock -> :me
    end

    dispatch.()

    assert_receive :done
  end

  def run_different_universe(dispatch) do
    test_pid = self()

    spawn(fn ->
      Multiverses.shard(PubSub)
      @pub_sub.subscribe(TestPubSub, "topic")
      send(test_pid, :unlock)

      refute_receive :foo

      send(test_pid, :done)
    end)

    receive do
      :unlock -> :me
    end

    dispatch.()

    assert_receive :done, 500
  end

  describe "with broadcast/3" do
    def broadcast do
      @pub_sub.broadcast(TestPubSub, "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&broadcast/0)
    end

    test "different_universe fails" do
      run_different_universe(&broadcast/0)
    end
  end

  describe "with broadcast!/3" do
    def broadcast! do
      @pub_sub.broadcast(TestPubSub, "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&broadcast!/0)
    end

    test "different_universe fails" do
      run_different_universe(&broadcast!/0)
    end
  end

  describe "with broadcast_from/4" do
    def broadcast_from do
      @pub_sub.broadcast_from(TestPubSub, self(), "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&broadcast_from/0)
    end

    test "different_universe fails" do
      run_different_universe(&broadcast_from/0)
    end
  end

  describe "with broadcast_from!/4" do
    def broadcast_from! do
      @pub_sub.broadcast_from!(TestPubSub, self(), "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&broadcast_from!/0)
    end

    test "different_universe fails" do
      run_different_universe(&broadcast_from!/0)
    end
  end

  describe "with direct_broadcast/4" do
    def direct_broadcast do
      @pub_sub.direct_broadcast(Node.self(), TestPubSub, "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&direct_broadcast/0)
    end

    test "different_universe fails" do
      run_different_universe(&direct_broadcast/0)
    end
  end

  describe "with direct_broadcast!/4" do
    def direct_broadcast! do
      @pub_sub.direct_broadcast!(Node.self(), TestPubSub, "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&direct_broadcast!/0)
    end

    test "different_universe fails" do
      run_different_universe(&direct_broadcast!/0)
    end
  end

  describe "with local_broadcast/3" do
    def local_broadcast do
      @pub_sub.local_broadcast(TestPubSub, "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&local_broadcast/0)
    end

    test "different_universe fails" do
      run_different_universe(&local_broadcast/0)
    end
  end

  describe "with local_broadcast_from/4" do
    def local_broadcast_from do
      @pub_sub.local_broadcast_from(TestPubSub, self(), "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&local_broadcast_from/0)
    end

    test "different_universe fails" do
      run_different_universe(&local_broadcast_from/0)
    end
  end
end
