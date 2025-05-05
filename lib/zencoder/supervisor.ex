defmodule Zencoder.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      %{
        id: Zencoder.Config,
        start: {Zencoder.Config, :start_link, []}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
