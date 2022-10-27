defmodule Multiverses.Presence do
  defmacro clone(initial, opts) do
    target = Keyword.fetch!(opts, :as)
    quote do
      defmodule unquote(target) do
        use Multiverses.Clone,
          module: unquote(initial),
          except: [
            fetch: 2, get_by_key: 2, list: 1,
            track: 4, untrack: 3, update: 4
          ]

        def fetch(topic, presences) do
          if is_binary(topic) do
            unquote(initial).fetch(Multiverses.PubSub.sharded(topic), presences)
          else
            # channel
            unquote(initial).fetch(topic, presences)
          end
        end

        def get_by_key(topic, presences) do
          if is_binary(topic) do
            unquote(initial).get_by_key(Multiverses.PubSub.sharded(topic), presences)
          else
            # channel
            unquote(initial).get_by_key(topic, presences)
          end
        end

        def list(topic) do
          if is_binary(topic) do
            unquote(initial).list(Multiverses.PubSub.sharded(topic))
          else
            # channel
            unquote(initial).list(topic)
          end
        end

        def track(pid, topic, key, meta) do
          unquote(initial).track(pid, Multiverses.PubSub.sharded(topic), key, meta)
        end

        def untrack(pid, topic, key) do
          unquote(initial).untrack(pid, Multiverses.PubSub.sharded(topic), key)
        end

        def update(pid, topic, key, meta) do
          unquote(initial).update(pid, Multiverses.PubSub.sharded(topic), key, meta)
        end
      end
    end
  end
end
