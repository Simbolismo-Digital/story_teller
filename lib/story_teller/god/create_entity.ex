defmodule StoryTeller.God.CreateEntity do
  def create(intent, prompt, struct) do
    {:ok, entities, _story} = StoryTeller.Llm.Gemini.chat(prompt, context(intent, struct))

    entities
    |> dbg()
    |> StoryTeller.Json.extract_json_block()
    |> Jason.decode!()
  end

  def context(intent, struct) do
    """
    Baseado nas intenções #{inspect(intent)}, crie e preencha os mapas #{inspect(struct)}.
    Retorne numa lista de mapas json.
    Não deixe campos nulos.
    Não coloque \n ou caractéres que formatem linhas.
    Para o seguinte prompt:
    """
  end
end
