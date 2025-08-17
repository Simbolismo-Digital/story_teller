defmodule StoryTeller.God.Brain do
  def plan(state, prompt) do
    StoryTeller.God.Intent.detect(state, prompt)
  end

  def execute(%{"intent" => "create_players"} = intent, prompt) do
    players = StoryTeller.God.CreateEntity.create(intent, prompt, %StoryTeller.Player{})
    # |> dbg()
    {intent, players}
  end

  def execute(intent, _prompt) do
    {intent, nil}
  end

  def respond({%{"intent" => "create_players"}, players}, _prompt, state) do
    {%{state | players: players ++ state.players},
     "Parabéns, #{Enum.map_join(players, ", ", & &1.name)}!"}
  end

  def respond(_plan, "", state) do
    {state, "Fale, viajante. Qual é o seu nome?"}
  end

  def respond(_plan, prompt, state) do
    {state, "Eu sou Deus. Você disse: #{prompt}"}
  end
end
