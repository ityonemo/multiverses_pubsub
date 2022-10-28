defmodule Multiverses.Tracker do
  @moduledoc """
  ## Using Multiverses With Phoenix Tracker

  Now set up your configuration:

  ### in `config.exs`

  ```elixir
  config :my_app, Phoenix.PubSub, Phoenix.PubSub
  config :my_app, Phoenix.Tracker, Phoenix.Tracker
  ```

  ### in `test.exs`

  ```elixir
  config :my_app, Phoenix.PubSub, Multiverse.PubSub
  config :my_app, Phoenix.Tracker, Multiverse.Tracker
  ```

  ### Create your tracker module

  implement a minimal tracker as follows:

  Note that the `handle_diff` callback will be executed in separate batches,
  one for each known universe shard.

  ```elixir
  defmodule MyApp.Tracker do
    use Phoenix.Tracker

    @phoenix_tracker Application.get_env(:my_app, Phoenix.Tracker)
    @phoenix_pubsub Application.get_env(:my_app, Phoenix.PubSub)

    def start_link(opts) do
      opts = Keyword.merge([name: __MODULE__], opts)
      @phoenix_tracker.start_link(__MODULE__, opts, opts)
    end

    def init(opts) do
      server = Keyword.fetch!(opts, :pubsub_server)
      {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
    end

    def handle_diff(diff, state) do
      for {topic, {joins, leaves}} <- diff do
        for {_key, meta} <- joins do
          @phoenix_pubsub.broadcast(...)
        end

        for {_key, meta} <- leaves do
          @phoenix_pubsub.broadcast(...)
        end
      end

      {:ok, state}
    end
  end
  ```

  ## wherever you use Tracker

  ```elixir
  defmodule MyApp.UsesTracker do
    @tracker Application.compile_env!(:my_app, Phoenix.Tracker)

    # ...
  end
  ```
  """

  use Multiverses.Clone,
    module: Phoenix.Tracker,
    except: [
      init: 1,
      get_by_key: 3,
      list: 2,
      start_link: 3,
      track: 5,
      untrack: 4,
      update: 5
    ]

  import Multiverses.PubSub, only: [_sharded: 1]

  @module :"$module"

  def start_link(module, srv_opts, gen_opts) do
    srv_opts = Keyword.put(srv_opts, @module, module)
    Phoenix.Tracker.start_link(__MODULE__, srv_opts, gen_opts)
  end

  def init(srv_opts) do
    module = Keyword.fetch!(srv_opts, @module)

    srv_opts
    |> Keyword.delete(@module)
    |> module.init()
    |> case do
      {:ok, state} -> {:ok, Map.put(state, :module, module)}
      other -> other
    end
  end

  def handle_diff(diff, state) do
    PubSub
    |> Multiverses.all()
    |> iterate_diff(diff, state)
  end

  defp iterate_diff([], _diff, state), do: {:ok, state}

  defp iterate_diff([id | rest], diff, state) do
    Multiverses.allow_for(PubSub, id, fn ->
      suffix = "-#{id}"

      case Enum.split_with(diff, &String.ends_with?(elem(&1, 0), suffix)) do
        {has, []} ->
          has
          |> Enum.map(&trim_topic(&1, suffix))
          |> Map.new()
          |> state.module.handle_diff(state)

        {[], hasnt} ->
          iterate_diff(rest, hasnt, state)

        {has, hasnt} ->
          has
          |> Enum.map(&trim_topic(&1, suffix))
          |> Map.new()
          |> state.module.handle_diff(state)
          |> case do
            {:ok, new_state} ->
              iterate_diff(rest, hasnt, new_state)

            error ->
              error
          end
      end
    end)
  end

  defp trim_topic({topic, diff}, suffix), do: {String.trim_trailing(topic, suffix), diff}

  def handle_info(info, state) do
    state.module.handle_info(info, state)
  end

  def get_by_key(tracker_name, topic, key) do
    Phoenix.Tracker.get_by_key(tracker_name, _sharded(topic), key)
  end

  def list(tracker_name, topic) do
    Phoenix.Tracker.list(tracker_name, _sharded(topic))
  end

  def track(tracker_name, pid, topic, key, meta) do
    Phoenix.Tracker.track(tracker_name, pid, _sharded(topic), key, meta)
  end

  def untrack(tracker_name, pid, topic, key) do
    Phoenix.Tracker.untrack(tracker_name, pid, _sharded(topic), key)
  end

  def update(tracker_name, pid, topic, key, meta) do
    Phoenix.Tracker.update(tracker_name, pid, _sharded(topic), key, meta)
  end
end
