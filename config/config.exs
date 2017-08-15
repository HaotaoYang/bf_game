# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :bf_game, BfGame.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XRk1tS4zZqKmMsOGsxLoYdvjzvi5NwwVr2aFwZQEyNkV3q1frKxTsgn6Qc1BRvcQ",
  render_errors: [view: BfGame.ErrorView, accepts: ~w(json)],
  pubsub: [name: BfGame.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# config :bf_game, :token,
#   url: "http://192.168.200.4:8080/v2/game/ge",
#   md5sign: "iomsk$"

config :bf_game, :queue_args,
  port: 5672,
  host: "127.0.0.1",
  username: "guest",
  password: "guest",
  virtual_host: "/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
