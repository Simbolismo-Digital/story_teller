defmodule StoryTeller.Player.Agent do
  use GenServer

  alias StoryTeller.Cli.TextFx
  alias StoryTeller.Player.Action, as: PlayerAction
  alias StoryTeller.Player
  alias StoryTeller.Repo
  ## API

  def start_link(%Player{name: name} = player) do
    GenServer.start_link(__MODULE__, player, name: via(name))
  end

  def get(name), do: GenServer.call(via(name), :get)
  def update(name, fun), do: GenServer.cast(via(name), {:update, fun})

  def action(actor_name, target_name, action \\ nil) do
    GenServer.call(via(actor_name), {:act_on, target_name, action})
  end

  ## Callbacks

  def init(player) do
    StoryTeller.Player.Action.ensure_ets()
    {:ok, player}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_cast({:update, fun}, state) do
    {:noreply, upsert!(state, fun.(state))}
  end

  def handle_call({:act_on, target_name, action}, _from, actor) do
    ts = NaiveDateTime.utc_now()

    action = action || actor.action

    event_for_actor = %{
      type: "outgoing_action",
      from: actor.name,
      to: target_name,
      action: action,
      at: ts
    }

    event_for_target = %{
      type: "incoming_action",
      from: actor.name,
      to: target_name,
      action: action,
      at: ts
    }

    # 1) ator lembra e persiste sua ação (campo action)
    actor1 =
      actor
      |> remember(event_for_actor)
      |> Map.put(:action, action)

    upsert!(actor, actor1)

    # 2) alvo lembra de forma sincronizada para garantir consistência
    {:ok, target1} =
      case GenServer.whereis(via(target_name)) do
        nil ->
          {:error, :target_not_found}

        _pid ->
          GenServer.call(via(target_name), {:remember, event_for_target})
      end

    # 3) dispara LLM com ambos os estados atualizados (assíncrono pra não travar loop)
    _ =
      Task.start(fn ->
        try do
          {:ok, result, changes} = PlayerAction.act(actor1, target1, action)
          target2 = upsert!(target1, changes)
          TextFx.type(result, wait: 200)
          TextFx.type("#{target2.name}: #{changes["action"]}", color: :green)
          # if target2.mode == :llm, do: action(target2.name, actor.name, target2.action)
        rescue
          e ->
            require Logger
            Logger.error("LLM react failed: #{Exception.message(e)}")
        end
      end)

    {:reply, :ok, actor1}
  end

  # usado pelo ator para pedir ao alvo lembrar
  def handle_call({:remember, event}, _from, state) do
    state1 = remember(state, event)
    {:reply, {:ok, state1}, state1}
  end

  ## Private

  @memory_cap 200
  defp remember(%Player{} = p, %{} = event) do
    mem = p.memory || []
    mem1 = [event | mem] |> Enum.take(@memory_cap)
    %Player{p | memory: mem1}
  end

  defp upsert!(%Player{} = player, %Player{} = changes) do
    attrs =
      changes
      |> Map.from_struct()
      |> Map.drop([:__meta__, :id, :inserted_at])

    upsert!(player, attrs)
  end

  defp upsert!(%Player{} = player, %{} = changes) do
    player
    |> Player.changeset(changes)
    |> Ecto.Changeset.put_change(
      :updated_at,
      NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :name
    )
  end

  ## Registry helper

  defp via(name), do: {:via, Registry, {StoryTeller.Player.Registry, name}}
end
