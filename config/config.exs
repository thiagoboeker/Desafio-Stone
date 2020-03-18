# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stoned,
  ecto_repos: [Stoned.Repo]

# Configures the endpoint
config :stoned, StonedWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "emdbDDlaF3qk/mOuCtIW+6GjR46Mh6lF+jjNl62gHYIMPFRQU3FkAEk9wwJ0B6s2",
  render_errors: [view: StonedWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Stoned.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stoned, :user_salt, "nmqEmk0ITJcDJyGXnGujD+rntPI7aNGAfrRaZe3aqx0zC59ZCcQgxRgj3Wfwsd1N"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
