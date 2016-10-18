defmodule Guardian.Roles.Role do
  defmacro __using__(_opts) do
    quote do

      import Guardian.Roles.Utils

      def find(%user_mod{} = user, %group_mod{} = site) do
        user = user |> repo.preload(:roles)
        Enum.filter(user.roles, fn(r) -> r.site_id == site.id end)
        |> List.last || struct(role_mod, %{site_id: site.id, user_id: user.id, role: 0})
      end

    end
  end
end