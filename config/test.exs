use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dots_server, DotsServer.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dots_server, DotsServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "dots_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
