defmodule Guardian.Roles.RoledUser do
  defmacro __using__(opts) do
    quote do
      import Guardian.Roles.Utils
      
      import Ecto.{Query, Changeset, Repo}

      @config unquote(opts)[:config]

      @default_perms %{   
        default:  [],   
        user:     [:primary, :secondary, :tertiary],    
        admin:    [:upload, :dashboard],    
        sys:      [:sys]    
      }

      def has_group_association(%user_mod{} = user, %group_mod{} = grp) when is_map(user) and is_map(grp),
        do: has_group_association(user, grp.id)
      def has_group_association(%user_mod{} = user, grp_id) when is_binary(grp_id),
        do: has_group_association(user, String.to_integer(grp_id))
      def has_group_association(%user_mod{} = user, grp_id) when is_integer(grp_id) do
        user = user |> repo.preload(group_name())
        Enum.filter(Map.get(user, group_name()), fn(s) -> s.id == grp_id end)
        |> length > 0
      end

      def role_default, do: 0
      def role_user_primary, do: 1
      def role_user_secondary, do: 2
      def role_user_tertiary, do: 3
      def role_admin_upload, do: 10
      def role_admin_dashboard, do: 50
      def role_sys_sys, do: 100

      def add_primary!(%user_mod{} = u, %group_mod{} = s), do: add_role(u, s, &role_user_primary/0)
      def add_secondary!(%user_mod{} = u, %group_mod{} = s), do: add_role(u, s, &role_user_secondary/0)
      def add_tertiary!(%user_mod{} = u, %group_mod{} = s), do: add_role(u, s, &role_user_tertiary/0)
      def add_upload!(%user_mod{} = u, %group_mod{} = s), do: add_role(u, s, &role_admin_upload/0)
      def add_admin!(%user_mod{} = u, %group_mod{} = s), do: add_role(u, s, &role_admin_dashboard/0)
      def add_sys!(%user_mod{} = u, %group_mod{} = s) do
        %{add_role(u, s, &role_sys_sys/0) | is_sys: true} # ephemeral
      end

      def make_primary!(%user_mod{} = u, %group_mod{} = s), do: make_role(u, s, &role_user_primary/0)
      def make_secondary!(%user_mod{} = u, %group_mod{} = s), do: make_role(u, s, &role_user_secondary/0)
      def make_tertiary!(%user_mod{} = u, %group_mod{} = s), do: make_role(u, s, &role_user_tertiary/0)
      def make_upload!(%user_mod{} = u, %group_mod{} = s), do: make_role(u, s, &role_admin_upload/0)
      def make_admin!(%user_mod{} = u, %group_mod{} = s), do: make_role(u, s, &role_admin_dashboard/0)
      def make_sys!(%user_mod{} = u, %group_mod{} = s) do
        make_role(%{u | is_sys: true}, s, &role_sys_sys/0) # update db
      end
      def revoke_sys!(%user_mod{} = u, _ \\ nil) do
        repo.changeset(u, %{is_sys: false}) # remove just the is_sys flag
        |> repo.update!
      end

      def is_default(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role == 0
      def is_user(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role > 0 and role_mod.find(u, s).role < 10
      def is_upload(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role == 10
      def is_admin(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role == 50

      def has_user(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role > 0
      def has_upload(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role >= 10
      def has_admin(%user_mod{} = u, %group_mod{} = s), do: role_mod.find(u, s).role >= 50
      
      def perms(%user_mod{} = u, :manager) do
        if u.is_sys do
          do_perms(u, role_sys_sys)
        else
          u_role = role_mod.find(u).role
          if u_role >= 50 do
            do_perms(u, u_role)
          else
            do_perms(u, role_default)
          end
        end
      end
      def perms(%user_mod{} = u, %group_mod{} = s) do
        do_perms(u, role_mod.find(u, s).role)
      end

      defp do_perms(%user_mod{} = u, u_role) when is_integer(u_role) do
        Dict.get(@config, :permissions) || @default_perms
          |> Map.delete(:sys)
          |> Enum.filter_map(fn({key, list}) when is_list(list) ->
               case list do
                 [h|l] = r ->
                   role_value(key, h) <= u_role
                 [] ->
                   false
               end
             end,
             &(filter_role(&1, u_role))) |> Enum.into(%{})
          |> Map.put_new(:default, [])
          |> maybe_sys(u)
      end

      defp role_value(key, permission) do
        :erlang.apply(__MODULE__, String.to_atom("role_#{key}_#{permission}"), [])
      end

      defp filter_role({key, roles}, user_role) do
        {key, Enum.filter(roles, fn(r) -> role_value(key, r) <= user_role end)}
      end

      defp maybe_sys(roles, user) do
        if user.is_sys, do: Map.put(roles, :sys, [:sys]), else: roles
      end

      defp add_role(%user_mod{} = u, %group_mod{} = s, role) do
        role_mod.find(u, s)
        |> (&cast(&1, %{role: max(&1.role, role.())}, ~w(role)a)).()
        |> repo.update!
        %{u | roles: repo.all(from r in role_mod, where: r.user_id == ^u.id)}
      end

      defp make_role(%user_mod{} = u, %group_mod{} = s, role) do
        role_mod.find(u, s)
        |> cast(%{role: role.()}, ~w(role)a)
        |> repo.update!
        %{u | roles: repo.all(from r in role_mod, where: r.user_id == ^u.id)}
      end

    end
  end
end