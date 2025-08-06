defmodule StoryTeller.PlayerAgent do
  @moduledoc """
  https://chatgpt.com/c/688f2896-5db4-8323-9f3a-635e41da6661

  1. Criar Agentes de Player

  2. Inicializar Players na Universe
    Enum.each(scene.players, fn player ->
      StoryTeller.PlayerAgent.start_link(player)
    end)

  3. Executar ações dos players dinamicamente
    No lugar de make_actions/2, altere a lógica do turno:
    actions =
      Enum.map(scene.players, fn p ->
        StoryTeller.PlayerAgent.act(p.name, scene)
      end)

  4. Mudar modo dinamicamente
  No IEx ou comando in-game:
    StoryTeller.PlayerAgent.set_mode("Lyra", :manual)

  5. (Opcional) Live CLI
    Você pode criar um módulo tipo StoryTeller.Console para controlar a história interativamente:

    def play_console do
      StoryTeller.Universe.play_n_turns(1)
      |> StoryTeller.Universe.print_story()
      play_console()  # loop
    end

  🚀 Expansões Futuras
    Persistência do estado dos agentes

    Temporizador (turnos com timeout)

    Interrupção/reação entre NPC e jogador

    Modo híbrido (usuário escreve ações de alguns, outros são automáticos)
  """
  # use GenServer

  # def start_link(%StoryTeller.Player{name: name} = player) do
  #   GenServer.start_link(__MODULE__, {player, :llm}, name: via(name))
  # end

  # def via(name), do: {:via, Registry, {StoryTeller.PlayerRegistry, name}}

  # def init({player, mode}) do
  #   {:ok, %{player: player, mode: mode, last_action: nil}}
  # end

  # def set_mode(name, mode), do: GenServer.cast(via(name), {:set_mode, mode})

  # def act(name, scene), do: GenServer.call(via(name), {:act, scene})

  # def handle_call({:act, scene}, _from, %{mode: :llm, player: p} = state) do
  #   {:ok, action} = StoryTeller.Llm.Gemini.ask_for_action(p, scene)
  #   {:reply, action, %{state | last_action: action}}
  # end

  # def handle_call({:act, scene}, _from, %{mode: :manual, player: p} = state) do
  #   IO.puts("\n🎭 [#{p.name}] Sua vez de agir:")
  #   action = IO.gets("> ") |> String.trim()
  #   {:reply, %{"character" => p.name, "action" => action}, %{state | last_action: action}}
  # end

  # def handle_cast({:set_mode, mode}, state), do: {:noreply, %{state | mode: mode}}
end
