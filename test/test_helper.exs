Application.put_env(:multiverses_pubsub, :use_multiverses, true)

# start a pubsub manually.  This pubsub server will be shared.
Supervisor.start_link(
  [{Phoenix.PubSub, name: TestPubSub}],
  strategy: :one_for_one)

ExUnit.start()
