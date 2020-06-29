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

  use Multiverses.MacroClone,
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

  defmacro universal(message) do
    quote do
      require Multiverses
      universe_slug = Multiverses.self()
      |> :erlang.term_to_binary
      |> Base.url_encode64

      IO.chardata_to_string([unquote(message), "-", universe_slug])
    end
  end

  defclone broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.broadcast(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic),
                             message,
                             dispatcher)
  end

  defclone broadcast!(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.broadcast!(pubsub,
                              Multiverses.Phoenix.PubSub.universal(topic),
                              message,
                              dispatcher)
  end

  defclone broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.broadcast_from(pubsub,
                                  from,
                                  Multiverses.Phoenix.PubSub.universal(topic),
                                  message,
                                  dispatcher)
  end

  defclone broadcast_from!(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.broadcast_from!(pubsub,
                                   from,
                                   Multiverses.Phoenix.PubSub.universal(topic),
                                   message,
                                   dispatcher)
  end

  defclone direct_broadcast(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.direct_broadcast(node_name,
                                    pubsub,
                                    Multiverses.Phoenix.PubSub.universal(topic),
                                    message,
                                    dispatcher)
  end

  defclone direct_broadcast!(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.direct_broadcast!(node_name,
                                     pubsub,
                                     Multiverses.Phoenix.PubSub.universal(topic),
                                     message,
                                     dispatcher)
  end

  defclone local_broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.local_broadcast(pubsub,
                                   Multiverses.Phoenix.PubSub.universal(topic),
                                   message,
                                   dispatcher)
  end

  defclone local_broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.local_broadcast_from(pubsub,
                                        from,
                                        Multiverses.Phoenix.PubSub.universal(topic),
                                        message,
                                        dispatcher)
  end

  defclone subscribe(pubsub, topic, opts \\ []) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.subscribe(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic),
                             opts)
  end

  defclone unsubscribe(pubsub, topic) do
    require Multiverses.Phoenix.PubSub
    Phoenix.PubSub.subscribe(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic))
  end

end
