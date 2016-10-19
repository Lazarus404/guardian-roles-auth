defmodule Guardian.Roles.Utils do
  def repo do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :repo)
  end
  def auth_mod do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :auth)
  end
  def user_mod do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :user)
  end
  def role_mod do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :role)
  end
  def group_mod do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :group)
  end
  def group_id do
    Dict.get(Application.get_env(:guardian_roles_auth, GuardianRolesAuth), :group_id)
  end
end