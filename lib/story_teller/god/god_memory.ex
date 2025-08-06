defmodule StoryTeller.God.Memory do
  alias StoryTeller.Player

  def resume() do
    data = load()

    :ok = spawn_entities(data)

    data
  end

  defp load() do
    %{players: Player.all()}
  end

  defp spawn_entities([%{} | _] = list), do: Enum.each(list, &spawn_entities/1)

  defp spawn_entities(%mod{} = struct) do
    if function_exported?(mod, :start_link, 1) do
      {:ok, _pid} = mod.start_link(struct)
    end

    struct
  end

  defp spawn_entities(%{} = map) do
    Enum.each(map, fn {_k, v} -> spawn_entities(v) end)
  end

  defp spawn_entities(_), do: :ok
end
