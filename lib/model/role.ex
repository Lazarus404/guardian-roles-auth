defmodule Guardian.Roles.Role do
  defmacro __using__(_opts) do
    quote do

      import Guardian.Roles.Utils

      def find(%user_mod{} = user, %group_mod{} = grp) do
        user = user |> repo.preload(:roles)
        criteria = %{user_id: user.id, role: 0} |> Map.put_new(group_id, grp.id)
        Enum.filter(user.roles, fn(r) -> Map.get(r, group_id) == grp.id end)
        |> List.last || struct(role_mod, criteria)
      end

    end
  end
end