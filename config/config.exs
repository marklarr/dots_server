# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :dots_server, DotsServer.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "VDQICLn6pwGuM8b5pA0TyWu9+EWrYOhKhAfkUQ+chlngk2yg9OUb5RgO2gyyNdNo",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: DotsServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :addict,
  secret_key: "243262243132242f527158497932572f49472e2f4c6d46774565616a4f",
  extra_validation: fn ({valid, errors}, user_params) -> {valid, errors} end, # define extra validation here
  user_schema: DotsServer.User,
  repo: DotsServer.Repo,
  from_email: "no-reply@example.com", # CHANGE THIS
  mailgun_domain: "fillme",
  mailgun_key: "fillme",
  mail_service: :mailgun
