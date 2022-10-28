import Config

config :multiverses, with_replicant: true

if config_env() != :prod do
  config :phoenix, :json_library, Jason
end
