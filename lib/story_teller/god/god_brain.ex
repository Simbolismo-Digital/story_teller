defmodule StoryTeller.God.Brain do
  def plan(%{players: []}), do: :set_players
  def plan(_), do: :default

  def execute(:set_players, _prompt) do
    {:set_players, nil}
  end

  def execute(plan, _prompt) do
    {plan, nil}
  end

  def respond({:set_players, _}, _prompt, state) do
    {%{state | players: [1]}, "Now you're good to go"}
  end

  def respond(_plan, "", state) do
    {state, "Fale, viajante. Qual é o seu nome?"}
  end

  def respond(_plan, prompt, state) do
    {state, "Eu sou Deus. Você disse: #{prompt}"}
  end
end
