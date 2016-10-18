defmodule Guardian.Roles.EnsureGroupAuthenticated do
  require Logger
  import Plug.Conn
  import Guardian.Roles.Utils

  def init(opts) do
    opts = Enum.into(opts, %{})
    key = Map.get(opts, :key, :default)
    grp_type = Map.get(opts, :grp_type, "group")
    %{key: key, grp_type: grp_type}
  end

  def call(conn, opts) do
    grp = group_mod |> group_mod.for_domain(conn.host) |> repo.one
    grp_type = get_group_type(conn, grp, Map.get(opts, :grp_type))
    key = Map.get(opts, :key)
    user = Guardian.Plug.current_resource(conn, key)
    if user == nil or grp_type == nil or not user_mod.has_group_association(user, grp_type) do
      conn |> put_status(403) |> assign(:guardian_failure, :forbidden) |> halt
    else
      conn
    end
  end

  defp get_group_type(conn, group, grp_type) do
    Map.get(conn.params, grp_type, Map.get(group || %{}, :id))
  end
end
