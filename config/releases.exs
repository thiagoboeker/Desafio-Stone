import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
port = System.fetch_env!("APP_PORT")
hostname = System.fetch_env!("APP_HOSTNAME")
pg_user = System.fetch_env!("PG_USER")
pg_password = System.fetch_env!("PG_PASSWORD")
pg_host = System.fetch_env!("PG_HOST")

config :stoned, StonedWeb.Endpoint,
  http: [:inet6, port: String.to_integer(port)],
  secret_key_base: secret_key_base

config :stoned, :app_port, port
config :stoned, :app_hostname, hostname

config :stoned, Stoned.Repo,
  username: pg_user,
  password: pg_password,
  database: "stoned_prod",
  hostname: pg_host,
  pool_size: 10
