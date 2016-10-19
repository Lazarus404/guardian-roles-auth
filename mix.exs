defmodule GuardianRolesAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :guardian_roles_auth,
     version: "0.1.0",
     elixir: "~> 1.3",
     package: [ maintainers: ["dgvncsz0f"],
                licenses: ["BSD-3"],
                links: %{"github" => "http://github.com/dgvncsz0f/zipflow"}
              ],
     description: description,
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:plug, "~> 1.2.1 or ~> 1.3"},
     {:dialyxir, "~> 0.3.5", only: :dev},
     {:ex_doc, "~> 0.13", only: :dev}]
  end

  defp description do
    """
    Central location for adding roles (my flavour) support to guardian 
    """
  end
end
