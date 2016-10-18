defmodule Guardian.Roles.GuardianSerializer do
  @behaviour Guardian.Serializer

  import Guardian.Roles.Utils

  def for_token(user = %user_mod{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, repo.get(user_mod, id) }
  def from_token(_), do: { :error, "Unknown resource type" }

end
