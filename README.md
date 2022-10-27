# Multiverses.PubSub

Multiverses support for Phoenix PubSub

## Installation

The package can be installed by adding `multiverses_pubsub` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:multiverses_pubsub, "~> 0.3.0", runtime: (Mix.env == :test)}
  ]
end
```

Docs can be found at [https://hexdocs.pm/multiverses_pubsub](https://hexdocs.pm/multiverses_pubsub).

## Testing

This library allows parallel testing:

```
REPLICATION=10 mix test
```
