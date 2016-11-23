defmodule Guardian.Roles.Role do
  defmacro __using__(_opts) do
    quote do

      import Guardian.Roles.Utils

      def find(%user_mod{} = user) do
        user = user |> repo.preload(:roles)
        default = %{user_id: user.id, role: 0}
        case user.roles do
          roles = [_|_] -> 
            Enum.reduce(roles, fn(r, acc) -> if acc.role < r.role, do: r, else: acc end) |> List.last
          _ ->
            default
        end
      end

      def find(%user_mod{} = user, %group_mod{} = grp) do
        user = user |> repo.preload(:roles)
        criteria = %{user_id: user.id, role: 0} |> Map.put_new(group_id, grp.id)
        Enum.filter(user.roles, fn(r) -> Map.get(r, group_id) == grp.id end)
          |> List.last || struct(role_mod, criteria)
      end

    end
  end
end