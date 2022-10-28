defmodule Multiverses.Tracker do
  @moduledoc """
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
          |> Map.new
          |> state.module.handle_diff(state)

        {[], hasnt} ->
          iterate_diff(rest, diff, state)

        {has, hasnt} ->
          has
          |> Enum.map(&trim_topic(&1, suffix))
          |> Map.new()
          |> state.module.handle_diff(state)
          |> case do
            {:ok, new_state} ->
              iterate_diff(rest, diff, new_state)

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
