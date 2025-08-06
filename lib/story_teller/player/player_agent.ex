defmodule StoryTeller.Player.Agent do
  use GenServer

  alias StoryTeller.Player
  alias StoryTeller.Repo
  ## API

  def start_link(%Player{name: name} = player) do
    GenServer.start_link(__MODULE__, player, name: via(name))
  end

  def get(name), do: GenServer.call(via(name), :get)
  def update(name, fun), do: GenServer.cast(via(name), {:update, fun})

  ## Callbacks

  def init(player), do: {:ok, player}

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_cast({:update, fun}, state) do
    {:noreply, upsert!(state, fun.(state))}
  end

  ## Private

  defp upsert!(%Player{} = player, %Player{} = changes) do
    attrs =
      changes
      |> Map.from_struct()
      |> Map.drop([:__meta__, :id, :inserted_at])
      |> Map.put(:updated_at, NaiveDateTime.utc_now())

    player
    |> Player.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :name
    )
  end

  ## Registry helper

  defp via(name), do: {:via, Registry, {StoryTeller.Player.Registry, name}}
end
