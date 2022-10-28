defmodule MultiversesTest.Presence do
  use Phoenix.Presence,
    otp_app: :multiverses_pubsub,
    pubsub_server: TestPubSub
end
