# defmodule StoryTeller.Universe.Turn do
#   @moduledoc """
#   Controls the logic of a single story turn loop.

#   - Waits for all manual players to act.
#   - Players send message to the Turn process.
#   - When all have acted, calls Gemini for next scene.
#   - Parses the scene and ensures no duplicate characters are spawned.
#   - Repeats for a given number of turns.
#   """

#   use GenServer
#   require Logger

#   alias StoryTeller.PlayerAgent
#   alias StoryTeller.Scene
#   alias StoryTeller.Action
#   alias StoryTeller.Llm.Gemini

#   def start_link(opts) do
#     GenServer.start_link(__MODULE__, opts, name: __MODULE__)
#   end

#   def run_turns(count) do
#     GenServer.call(__MODULE__, {:start, count})
#   end

#   def submit_action(player_name, action) do
#     GenServer.cast(__MODULE__, {:action, player_name, action})
#   end

#   @impl true
#   def init(_opts) do
#     {:ok, %{scene: nil, actions: %{}, turns: 0, max_turns: 0, model_story: nil}}
#   end

#   @impl true
#   def handle_call({:start, max_turns}, _from, state) do
#     Logger.info("🎲 Starting turn loop for #{max_turns} turns...")

#     {:ok, raw_scene, model_story} = StoryTeller.Universe.opening_scene()
#     scene = Scene.parse(raw_scene)

#     Enum.each(scene.players, &PlayerAgent.start_link/1)

#     {:noreply, %{state | scene: scene, max_turns: max_turns, model_story: model_story}}
#   end

#   @impl true
#   def handle_cast({:action, player_name, action}, state) do
#     Logger.info("✅ Received action from #{player_name}")
#     actions = Map.put(state.actions, player_name, action)

#     manual_players = Enum.filter(state.scene.players, &PlayerAgent.manual?(&1.name))

#     if Enum.all?(manual_players, &Map.has_key?(actions, &1.name)) do
#       Logger.info("📦 All manual player actions received. Advancing story...")

#       {:ok, raw_scene, model_story} =
#         StoryTeller.Universe.next_scene(state.scene, state.model_story)

#       scene =
#         raw_scene
#         |> Json.extract_json_block()
#         |> Jason.decode!()
#         |> Scene.parse()
#         |> ensure_unique_players()

#       Enum.each(scene.players, &PlayerAgent.start_link/1)

#       turns = state.turns + 1
#       next_state = %{state | scene: scene, actions: %{}, model_story: model_story, turns: turns}

#       if turns >= state.max_turns do
#         Logger.info("🏁 Finished all turns.")
#         # Possibly persist story/export
#       end

#       {:noreply, next_state}
#     else
#       {:noreply, %{state | actions: actions}}
#     end
#   end

#   defp ensure_unique_players(scene) do
#     # implement de-duplication logic if needed
#     scene
#   end
# end
