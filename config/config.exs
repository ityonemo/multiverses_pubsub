import Config

config :multiverses_pubsub, strict: true
config :multiverses, with_replicant: config_env() == :test
