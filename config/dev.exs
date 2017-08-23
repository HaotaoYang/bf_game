use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :bf_game, BfGame.Endpoint,
  http: [port: 4396],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# start env
config :bf_game, start_env: :dev

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
