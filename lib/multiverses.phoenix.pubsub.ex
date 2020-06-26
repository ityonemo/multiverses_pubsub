defmodule Multiverses.Phoenix.PubSub do
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
      Multiverses.self()
      |> :erlang.term_to_binary
      |> Base.url_encode64
      |> Kernel.<>("-")
      |> Kernel.<>(unquote(message))
    end
  end

  defclone broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic),
                             message,
                             dispatcher)
  end

  defclone broadcast!(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast!(pubsub,
                              Multiverses.Phoenix.PubSub.universal(topic),
                              message,
                              dispatcher)
  end

  defclone broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from(pubsub,
                                  from,
                                  Multiverses.Phoenix.PubSub.universal(topic),
                                  message,
                                  dispatcher)
  end

  defclone broadcast_from!(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from!(pubsub,
                                   from,
                                   Multiverses.Phoenix.PubSub.universal(topic),
                                   message,
                                   dispatcher)
  end

  defclone direct_broadcast(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast(node_name,
                                    pubsub,
                                    Multiverses.Phoenix.PubSub.universal(topic),
                                    message,
                                    dispatcher)
  end

  defclone direct_broadcast!(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast!(node_name,
                                     pubsub,
                                     Multiverses.Phoenix.PubSub.universal(topic),
                                     message,
                                     dispatcher)
  end

  defclone local_broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast(pubsub,
                                   Multiverses.Phoenix.PubSub.universal(topic),
                                   message,
                                   dispatcher)
  end

  defclone local_broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast_from(pubsub,
                                        from,
                                        Multiverses.Phoenix.PubSub.universal(topic),
                                        message,
                                        dispatcher)
  end

  defclone subscribe(pubsub, topic, opts \\ []) do
    Phoenix.PubSub.subscribe(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic),
                             opts)
  end

  defclone unsubscribe(pubsub, topic) do
    Phoenix.PubSub.subscribe(pubsub,
                             Multiverses.Phoenix.PubSub.universal(topic))
  end

end
