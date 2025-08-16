defmodule StoryTeller.Cli.TextFx do
  @moduledoc false

  @modifier 0.25

  # API: aceita string ou lista + opts (ex.: color: :gold, device: :standard_error)
  def type(text, opts \\ [])
  def type(text, opts) when is_binary(text), do: type(List.wrap(text), opts)

  def type(paragraphs, opts) when is_list(paragraphs) do
    device = Keyword.get(opts, :device, :standard_error)
    prefix = ansi_prefix(opts)
    suffix = ansi_suffix(opts)

    Enum.each(paragraphs, fn para -> do_type(para, device, prefix, suffix) end)
    :ok
  end

  defp do_type(text, device, prefix, suffix) do
    IO.write(device, prefix)

    text
    |> String.replace("\n", "")                # remove indent após \n
    |> String.replace(~r/\s+/, " ")            # normaliza espaços
    |> then(&(&1 <> "\n"))
    |> String.normalize(:nfc)
    |> String.graphemes()
    |> Enum.each(fn g ->
      case g do
        "\n" ->
          IO.write(device, "\n")
          Process.sleep(400)

        _ ->
          IO.write(device, g)
          Process.sleep(delay_ms(g))
      end
    end)

    IO.write(device, suffix)
  end

  # pausa básica + jitter + extra se for pontuação
  defp delay_ms(g) do
    base = 25
    jitter = :rand.uniform(15) - 8

    punct_extra =
      cond do
        g in [".", "!", "?", "…"] -> 120
        g in [",", ";", ":"]      -> 60
        true                      -> 0
      end

    (max(base + jitter + punct_extra, 0) * @modifier)
    |> trunc()
  end

  # -------- ANSI helpers --------

  defp ansi_prefix(opts) do
    case Keyword.get(opts, :color) do
      nil       -> ""
      :yellow   -> IO.ANSI.yellow()
      :gold     -> ansi_gold()
      {:rgb, r, g, b} when is_integer(r) and is_integer(g) and is_integer(b) ->
        ansi_rgb(r, g, b)
      other when is_binary(other) -> other
      _ -> ""
    end
  end

  defp ansi_suffix(_opts), do: IO.ANSI.reset()

  # tenta 24-bit truecolor; se não rolar, cai pra :yellow
  defp ansi_gold do
    ansi_rgb(255, 215, 0) || IO.ANSI.yellow()
  end

  # usa truecolor (38;2;r;g;b). `IO.ANSI.color/3` existe nas versões recentes.
  defp ansi_rgb(r, g, b) do
    try do
      IO.ANSI.color(r, g, b)
    rescue
      _ -> "\e[38;2;#{r};#{g};#{b}m"
    end
  end
end
