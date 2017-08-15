defmodule BfGame.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bf_game,
      version: "0.0.1",
      elixir: "~> 1.6.0-dev",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BfGame, []},
      extra_applications: [:mnesia, :logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:amqp, "~> 0.2.3"},
      {:httpoison, "~> 0.13.0"},
      {:distillery, "~> 1.4"}
    ]
  end
end
