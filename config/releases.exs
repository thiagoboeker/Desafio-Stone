
import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
port = System.fetch_env!("APP_PORT")
hostname = System.fetch_env!("APP_HOSTNAME")
pg_user = System.fetch_env!("PG_USER")
pg_password = System.fetch_env!("PG_PASSWORD")
pg_host = System.fetch_env!("PG_HOST")
database_url = System.fetch_env!("DATABASE_URL")

config :stoned, StonedWeb.Endpoint,
  http: [:inet6, port: String.to_integer(port)],
  url: [scheme: "https", host: "hostname", port: 443]
  secret_key_base: secret_key_base,
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :stoned, :app_port, port
config :stoned, :app_hostname, hostname

config :stoned, Stoned.Repo,
  ssl: true,
  url: database_url,
  pool_size: 10
