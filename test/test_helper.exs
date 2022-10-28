Application.put_env(:multiverses_pubsub, :use_multiverses, true)

# start a pubsub manually.  This pubsub server will be shared.
Supervisor.start_link(
  [
    {Phoenix.PubSub, name: TestPubSub},
    MultiversesTest.Presence,
    {MultiverseTest.Tracker, name: TestTracker, pubsub_server: TestPubSub}
  ],
  strategy: :one_for_one
)

Task.start_link(fn ->
  System.cmd("epmd", [])
end)

Process.sleep(100)
{:ok, _} = :net_kernel.start([:primary, :shortnames])
:peer.start(%{name: :peer})
[peer] = Node.list()
:rpc.call(peer, :code, :add_paths, [:code.get_path()])
:rpc.call(peer, Application, :ensure_all_started, [:mix])
:rpc.call(peer, Application, :ensure_all_started, [:logger])
:rpc.call(peer, Logger, :configure, [[level: Logger.level()]])
:rpc.call(peer, Mix, :env, [Mix.env()])
:rpc.call(peer, Application, :ensure_all_started, [:multiverses_pubsub])
:rpc.call(peer, Application, :ensure_all_started, [:phoenix_pubsub])
:rpc.call(peer, Peer.PubSub, :start_unlinked, [])

ExUnit.start()
