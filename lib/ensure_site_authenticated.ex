defmodule Guardian.Roles.EnsureSiteAuthenticated do
  require Logger
  import Plug.Conn
  import Guardian.Roles.Utils

  def init(opts) do
    opts = Enum.into(opts, %{})
    key = Map.get(opts, :key, :default)
    site_id = Map.get(opts, :site_id, "site_id")
    %{key: key, site_id: site_id}
  end

  def call(conn, opts) do
    grp = group_mod |> group_mod.for_domain(conn.host) |> repo.one
    site_id = get_site_id(conn, grp, Map.get(opts, :site_id))
    key = Map.get(opts, :key)
    user = Guardian.Plug.current_resource(conn, key)
    if user == nil or site_id == nil or not user_mod.has_site_association(user, site_id) do
      conn |> put_status(403) |> assign(:guardian_failure, :forbidden) |> halt
    else
      conn
    end
  end

  defp get_site_id(conn, site, site_id) do
    Map.get(conn.params, site_id, Map.get(site || %{}, :id))
  end
end
