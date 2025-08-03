defmodule StoryTeller.Llm.Gemini do
  @moduledoc """
  Módulo para interagir com a API do Google Generative Language.

  Cheque a documentação oficial
  https://ai.google.dev/gemini-api/docs/get-started/tutorial?lang=rest&hl=pt-br
  """
  @url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"

  require Logger

  alias StoryTeller.Llm.GeminiLimiter

  def chat(context, prompt, story \\ []) do
    dbg(prompt)
    {:ok, tokens} = GeminiLimiter.estimate_tokens(context, prompt)

    GeminiLimiter.run(tokens, fn ->
      do_chat(context, prompt, story)
    end)
  end

  defp do_chat(context, prompt, story) do
    contents = contents(context, prompt, story)

    body =
      %{contents: contents}
      |> Jason.encode!()

    headers = [{"Content-Type", "application/json"}]

    Finch.build(:post, "#{@url}?key=#{api_key()}", headers, body)
    |> Finch.request(StoryTeller.Finch)
    |> handle_response(contents)
  end

  defp contents(context, prompt, []) do
    [
      %{
        role: "user",
        parts: [
          %{text: context},
          %{text: prompt}
        ]
      }
    ]
  end

  defp contents(_context, prompt, story) do
    story ++
      [
        %{
          role: "user",
          parts: [
            %{text: prompt}
          ]
        }
      ]
  end

  defp add_story(contents, answer) do
    contents ++
      [
        %{
          role: "model",
          parts: [
            %{text: answer}
          ]
        }
      ]
  end

  defp handle_response(
         {:ok, %Finch.Response{status: 200, body: body, headers: headers}},
         contents
       ) do
    Logger.debug(
      "📦 Headers recebidos:\n#{Enum.map_join(headers, "\n", fn {k, v} -> "#{k}: #{v}" end)}"
    )

    case Jason.decode(body) do
      {:ok, %{"candidates" => [%{"content" => %{"parts" => candidate}} | _]}} ->
        answer =
          candidate
          |> Enum.at(0)
          |> Map.get("text", "...")

        {:ok, answer, add_story(contents, answer)}

      {:ok, %{"candidates" => [%{"finishReason" => "SAFETY"} | _]}} ->
        Logger.warning("Erro ao processar a resposta: #{body}")

        {:ok, "...", add_story(contents, "...")}

      _ ->
        Logger.error("Erro ao processar a resposta: #{body}")

        {:error, "Erro ao processar a resposta", contents}
    end
  end

  defp handle_response({:ok, %Finch.Response{status: status, body: body}}, contents) do
    {:error, "Request failed with status #{status}: #{body}", contents}
  end

  defp handle_response({:error, reason}, contents) do
    {:error, reason, contents}
  end

  defp api_key() do
    Application.fetch_env!(:story_teller, :gemini)[:api_key]
  end
end
