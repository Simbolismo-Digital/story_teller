defmodule StoryTeller.Cli.TextFx do
  @moduledoc false

  @modifier 0.25

  def type(paragraphs) when is_list(paragraphs) do
    Enum.each(paragraphs, &do_type(&1))
    :ok
  end

  defp do_type(text) do
    text
    |> String.replace("\n", "") # remove indent após \n
    |> String.replace(~r/\s+/, " ")
    |> then(& &1 <> "\n")
    |> String.normalize(:nfc)
    |> String.graphemes()
    |> Enum.each(fn g ->
      case g do
        "\n" ->
          IO.write(:standard_error, "\n")
          Process.sleep(400)

        _ ->
          IO.write(:standard_error, g)
          Process.sleep(delay_ms(g))
      end
    end)
  end

  # pausa básica + jitter + extra se for pontuação
  defp delay_ms(g) do
    base   = 25                       # ~40 cps em média
    jitter = (:rand.uniform(15) - 8)  # -8..+7 ms
    punct_extra =
      cond do
        g in [".", "!", "?", "…"] -> 120
        g in [",", ";", ":"]      -> 60
        true -> 0
      end

     max(base + jitter + punct_extra, 0) * @modifier
     |> trunc()
  end
end
