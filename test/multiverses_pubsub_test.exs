import MultiversesTest.Replicant

defmoduler Multiverses.PubsubTest do
  use ExUnit.Case, async: true
  use Multiverses, with: Phoenix.PubSub

  def run_same_universe(dispatch) do
    test_pid = self()

    Task.async(fn ->
      PubSub.subscribe(TestPubSub, "topic")
      send(test_pid, :unlock)

      assert_receive :foo

      send(test_pid, :done)
    end)

    receive do :unlock -> :me end

    dispatch.()

    assert_receive :done
  end

  def run_different_universe(dispatch) do
    test_pid = self()

    spawn(fn ->
      PubSub.subscribe(TestPubSub, "topic")
      send(test_pid, :unlock)

      refute_receive :foo

      send(test_pid, :done)
    end)

    receive do :unlock -> :me end

    dispatch.()

    assert_receive :done, 500
  end

  describe "with broadcast/3" do
    def broadcast do
      PubSub.broadcast(TestPubSub, "topic", :foo)
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
      PubSub.broadcast(TestPubSub, "topic", :foo)
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
      PubSub.broadcast_from(TestPubSub, self(), "topic", :foo)
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
      PubSub.broadcast_from!(TestPubSub, self(), "topic", :foo)
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
      PubSub.direct_broadcast(Node.self(), TestPubSub, "topic", :foo)
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
      PubSub.direct_broadcast!(Node.self(), TestPubSub, "topic", :foo)
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
      PubSub.local_broadcast(TestPubSub, "topic", :foo)
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
      PubSub.local_broadcast_from(TestPubSub, self(), "topic", :foo)
    end

    test "same_universe works" do
      run_same_universe(&local_broadcast_from/0)
    end

    test "different_universe fails" do
      run_different_universe(&local_broadcast_from/0)
    end
  end
end
