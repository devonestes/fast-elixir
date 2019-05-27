defmodule FastElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :fast_elixir,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Type "mix help deps" for more information
  defp deps do
    [{:benchee, "~> 1.0"}]
  end
end
