defmodule Multiverses.Phoenix.PubSub do
  @moduledoc """
  Implements the `Multiverses` pattern for `Phoenix.PubSub`.

  Messages topics are sharded by postfixing the topic with a universe id.
  Processes in any given universe are then only capable of subscribing to
  messages sent within the same universe.

  ## Usage

  ```
  use Multiverses, with: Phoenix.PubSub
  ```

  and in that module use the `PubSub` alias as if you had the
  `alias Phoenix.PubSub` directive.

  To use with `Phoenix.Presence`, see:
  [Using Multiverses with Phoenix Presence](phoenix-presence.html)

  ## Warning

  This system should not be used in production to achieve sharding of
  communications channels.

  ## Important

  This does not shard across phoenix channels, as each channel will presumably
  already exist in the context of its own test shard and have requisite
  `:"$callers"` implemented by other functionality.
  """

  use Multiverses.Clone,
    module: Phoenix.PubSub,
    except: [
      broadcast: 3, broadcast: 4,
      broadcast!: 3, broadcast!: 4,
      broadcast_from: 4, broadcast_from: 5,
      broadcast_from!: 4, broadcast_from!: 5,
      direct_broadcast: 4, direct_broadcast: 5,
      direct_broadcast!: 4, direct_broadcast!: 5,
      local_broadcast: 3, local_broadcast: 4,
      local_broadcast_from: 4, local_broadcast_from: 5,
      subscribe: 2, subscribe: 3,
      unsubscribe: 2,
    ]

  require Multiverses

  def universal(message) do
    universe_slug = Multiverses.self()
    |> :erlang.term_to_binary
    |> Base.url_encode64

    IO.chardata_to_string([message, "-", universe_slug])
  end

  def broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast(pubsub,
                             universal(topic),
                             message,
                             dispatcher)
  end

  def broadcast!(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast!(pubsub,
                              universal(topic),
                              message,
                              dispatcher)
  end

  def broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from(pubsub,
                                  from,
                                  universal(topic),
                                  message,
                                  dispatcher)
  end

  def broadcast_from!(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from!(pubsub,
                                   from,
                                   universal(topic),
                                   message,
                                   dispatcher)
  end

  def direct_broadcast(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast(node_name,
                                    pubsub,
                                    universal(topic),
                                    message,
                                    dispatcher)
  end

  def direct_broadcast!(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast!(node_name,
                                     pubsub,
                                     universal(topic),
                                     message,
                                     dispatcher)
  end

  def local_broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast(pubsub,
                                   universal(topic),
                                   message,
                                   dispatcher)
  end

  def local_broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast_from(pubsub,
                                        from,
                                        universal(topic),
                                        message,
                                        dispatcher)
  end

  def subscribe(pubsub, topic, opts \\ []) do
    Phoenix.PubSub.subscribe(pubsub,
                             universal(topic),
                             opts)
  end

  def unsubscribe(pubsub, topic) do
    Phoenix.PubSub.subscribe(pubsub,
                             universal(topic))
  end

end
