defmodule Zencoder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :zencoder,
      version: "1.0.1",
      elixir: "~> 1.16",
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      package: [
        contributors: ["Adam Kittelson"],
        licenses: ["MIT"],
        links: %{ github: "https://github.com/zencoder/zencoder-ex", zencoder: "https://zencoder.com" },
        files: ["lib/*", "mix.exs", "README.md", "LICENSE"]
      ],
      description: "Elixir API wrapper for the Zencoder video transcoding API."
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpotion, :poison],
     mod: {Zencoder, []}]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  def deps do
    [
      {:httpotion, "~> 3.1"},
      {:ibrowse, "~> 4.4"},
      {:poison, "~> 2.0"},
      {:meck, "~> 0.9.2",        only: [:test]}
    ]
  end

end
