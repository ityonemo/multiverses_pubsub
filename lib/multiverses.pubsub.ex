defmodule Multiverses.PubSub do
  @moduledoc """
  Implements the `Multiverses` pattern for `Phoenix.PubSub`.

  Messages topics are sharded by postfixing the topic with the universe id.
  Processes in any given universe are then only capable of subscribing to
  messages sent within the same universe.

  > ## Don't use this in prod {: .warning}
  >
  > This system should not be used in production to achieve sharding of
  > communications channels.

  > ## Phoenix channels {: .warning}
  >
  > This does not currently support phoenix channels.  PRs or test cases accepted.

  ## Recommended Setup

  ### in `config.exs`

  ```elixir
  config :my_app, Phoenix.PubSub, Phoenix.PubSub
  ```

  ### in `test.exs`

  ```elixir
  config :my_app, Phoenix.PubSub, Multiverse.PubSub
  ```

  ### in your pubsub-using modules

  ```elixir
  defmodule MyPubSubModule do
    @pubsub Application.compile_env!(:my_app, Phoenix.PubSub)
  end
  ```

  ### in your tests

  ```elixir
  defmodule ModuleThatTestsPubSubTest do
    use ExUnit.Case, async: true

    setup do
      Multiverses.shard(PubSub)
    end

  end
  ```

  ## Configuration

  Many PubSub applications will have subscriber processes that won't be attached to a test, but
  still need to use the `Multiverses.PubSub` interface for ad-hoc processes created.  In this case,
  provide the following line in your configuration:

  Note that the default is to have `strict: true`

  ### in `test.exs`

  ```elixir
  config :multiverses_pubsub, strict: false
  ```

  ## Clustering

  `Multiverses.PubSub` is tested to work in clustered elixir.

  > ### Connecting processes to shards over the cluster {: .warning}
  >
  > Note that if a process is running in a peer node, you should provide it with either:
  > - the universe id to link it
  > - a pid that has been sent over erlang distribution.
  > If you provide a binary serialized pid (via `:erlang.term_to_binary/1`) the rehydrated
  > pid will not be connected to the correct multiverse shard.
  """

  use Multiverses.Clone,
    module: Phoenix.PubSub,
    except: [
      broadcast: 3,
      broadcast: 4,
      broadcast!: 3,
      broadcast!: 4,
      broadcast_from: 4,
      broadcast_from: 5,
      broadcast_from!: 4,
      broadcast_from!: 5,
      direct_broadcast: 4,
      direct_broadcast: 5,
      direct_broadcast!: 4,
      direct_broadcast!: 5,
      local_broadcast: 3,
      local_broadcast: 4,
      local_broadcast_from: 4,
      local_broadcast_from: 5,
      subscribe: 2,
      subscribe: 3,
      unsubscribe: 2
    ]

  @strict Application.compile_env(:multiverses_pubsub, :strict, true)

  def sharded(topic) do
    shard = if id = Multiverses.id(PubSub, strict: @strict), do: "-#{id}"
    "#{topic}#{shard}"
  end

  def broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast(
      pubsub,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def broadcast!(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast!(
      pubsub,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from(
      pubsub,
      from,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def broadcast_from!(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.broadcast_from!(
      pubsub,
      from,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def direct_broadcast(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast(
      node_name,
      pubsub,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def direct_broadcast!(node_name, pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.direct_broadcast!(
      node_name,
      pubsub,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def local_broadcast(pubsub, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast(
      pubsub,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def local_broadcast_from(pubsub, from, topic, message, dispatcher \\ Phoenix.PubSub) do
    Phoenix.PubSub.local_broadcast_from(
      pubsub,
      from,
      sharded(topic),
      message,
      dispatcher
    )
  end

  def subscribe(pubsub, topic, opts \\ []) do
    Phoenix.PubSub.subscribe(
      pubsub,
      sharded(topic),
      opts
    )
  end

  def unsubscribe(pubsub, topic) do
    Phoenix.PubSub.subscribe(
      pubsub,
      sharded(topic)
    )
  end
end
