defmodule StoryTeller.God.Brain do
  def plan(state, prompt) do
    StoryTeller.God.Intent.detect(state, prompt)
  end

  def execute(%{"intent" => current} = intent, prompt)
      when current in ["create_players", "select_players"] do
    players = StoryTeller.God.CreateEntity.create(intent, prompt, %StoryTeller.Player{})
    # |> dbg()
    {intent, players}
  end

  def execute(intent, _prompt) do
    {intent, nil}
  end

  def respond({%{"intent" => current}, players}, _prompt, state)
      when current in ["create_players", "select_players"] do
    {%{state | players: players ++ state.players},
     "Parabéns, #{Enum.map_join(players, ", ", & &1.name)}!"}
  end

  def respond(_plan, "", state) do
    {state, "Fale, viajante. Qual é o seu nome?"}
  end

  def respond(plan, prompt, state) do
    dbg(plan)
    {state, "Eu sou Deus. Você disse: #{prompt}"}
  end
end
