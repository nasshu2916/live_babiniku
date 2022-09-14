import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_babiniku, LiveBabinikuWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ws0KLo4AaKKdYpfXUnajJt7vaqroX/MrRCs+hORT9Av0QjirwbMoELxf4OZ4qiAS",
  server: false

# In test we don't send emails.
config :live_babiniku, LiveBabiniku.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
