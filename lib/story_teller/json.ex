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

    case Regex.run(~r/(\{(?:.|\n)*\})/, text) do
      [_, json] ->
        Logger.info("✅ JSON block extracted successfully.")
        json

      _ ->
        Logger.warning("⚠️ No JSON block found. Returning original text as error.")
        {:error, text}
    end
  end
end
