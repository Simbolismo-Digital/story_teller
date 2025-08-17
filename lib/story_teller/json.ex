defmodule StoryTeller.Json do
  require Logger

  @doc """
  Extracts the first JSON block from a text using regex.
  Returns:
    - JSON string if matched
    - {:error, original_text} if not found
  """
  def extract_json_block(text) when is_binary(text) do
    Logger.debug("🔍 Attempting to extract JSON block...")

    cond do
      Regex.match?(~r/```json\s*(\[.*?\]|\{.*?\})\s*```/ms, text) ->
        [_, json] = Regex.run(~r/```json\s*(\[.*?\]|\{.*?\})\s*```/ms, text)
        Logger.info("✅ JSON block (fenced) extracted successfully.")
        json

      Regex.match?(~r/(\[\s*\{.*?\}\s*\])/s, text) ->
        [_, json] = Regex.run(~r/(\[\s*\{.*?\}\s*\])/s, text)
        Logger.info("✅ JSON array extracted successfully.")
        json

      Regex.match?(~r/(\{(?:.|\n)*\})/, text) ->
        [_, json] = Regex.run(~r/(\{(?:.|\n)*\})/, text)
        Logger.info("✅ JSON object extracted successfully.")
        json

      true ->
        Logger.warning("⚠️ No JSON block found.")
        {:error, text}
    end
  end
end
