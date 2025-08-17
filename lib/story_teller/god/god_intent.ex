defmodule StoryTeller.God.Intent do
  alias StoryTeller.Llm.Gemini

  def detect(state, prompt) do
    {:ok, intent, _story} =
      Gemini.chat(
        prompt,
        context(state)
      )

    intent
    |> StoryTeller.Json.extract_json_block()
    |> Jason.decode!()
  end

  def context(state) do
    """
    Você é um mestre de rpg personificado como Deus interagindo com o jogador.

    Baseado no estado atual do GenServer #{inspect(state)}
    responda somente um  json {intent: "intent_name", subjects: ["subject1", "subject2"]}
    para as possíveis intenções do usuário:
    ["create_players", "select_players", "default"]

    Se os nomes dos players não existirem, a intenção é create_players, adicione os subjects a serem criados.
    Se os players já existirem, a intenção é select_players, adicione os subjects a serem selecionados.

    Se você identificar alguma outra intenção válida, reporte.

    Se não identificar nada de útil pode mandar "default".
    """
  end
end
