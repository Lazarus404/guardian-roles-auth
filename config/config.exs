# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

user_permissions = %{
  default:  [],
  user:     [:primary, :secondary, :tertiary],
  admin:    [:upload, :dashboard],
  sys:      [:sys]
}

config :guardian, Guardian,
  issuer: "innov8estate.com",
  allowed_algos: ["RS256"],
  ttl: {30, :days},
  verify_issuer: true,
  serializer: Guardian.Roles.GuardianSerializer,
  secret_key: to_string(Mix.env),
  hooks: GuardianDb,
  permissions: user_permissions

config :guardian_db, GuardianDb,
       repo: Guardian.Roles.Auth.Repo,
       sweep_interval: 120

config :dataroom, Guardian.Roles.Auth.Repo,
  adapter: Ecto.Adapters.Postgres