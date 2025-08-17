defmodule StoryTeller.God.Brain do
  def plan(state, prompt) do
    StoryTeller.God.Intent.detect(state, prompt)
  end

  def execute(%{"intent" => "create_players"} = intent, prompt) do
    StoryTeller.God.CreateEntity.create(intent, prompt, %StoryTeller.Player{}) |> dbg()
    {intent, prompt}
  end

  def execute(intent, _prompt) do
    {intent, nil}
  end

  def respond({%{"intent" => "create_players"}, player}, _prompt, state) do
    {%{state | players: [player]}, "Parabéns, #{player}!"}
  end

  def respond(_plan, "", state) do
    {state, "Fale, viajante. Qual é o seu nome?"}
  end

  def respond(_plan, prompt, state) do
    {state, "Eu sou Deus. Você disse: #{prompt}"}
  end
end
