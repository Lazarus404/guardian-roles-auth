defmodule GuardianRolesAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :guardian_roles_auth,
     version: "0.1.1",
     elixir: "~> 1.3",
     package: [ maintainers: ["Lazarus404"],
                licenses: ["BSD-3"],
                links: %{"github" => "http://github.com/Lazarus404/guardian-roles-auth"}
              ],
     description: description,
     elixirc_paths: elixirc_paths(Mix.env),
     # build_embedded: Mix.env == :prod,
     # start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [
      :plug,
      :logger,
      :comeonin,
      :ueberauth_identity
    ]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:plug, "~> 1.2.1 or ~> 1.3"},
     {:dialyxir, "~> 0.3.5", only: :dev},
     {:ex_doc, "~> 0.13", only: :dev},
     {:poison, "~> 2.2", override: true},
     {:guardian, "~> 0.13.0", override: true},
     {:guardian_db, "0.7.0"},
     {:ueberauth, github: "ueberauth/ueberauth", override: true},
     {:ueberauth_identity, "~>0.2.3"},
     {:comeonin, "~> 2.5"}]
  end

  defp description do
    """
    Central location for adding roles (my flavour) support to guardian 
    """
  end
end
