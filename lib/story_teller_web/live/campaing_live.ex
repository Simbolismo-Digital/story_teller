defmodule StoryTellerWeb.CampaingLive do
  use StoryTellerWeb, :live_view

  def mount(_params, _session, socket) do
    characters = [
      %{name: "Hero", action: nil, acted?: false},
      %{name: "NPC", action: nil, acted?: false},
      %{name: "Ally", action: nil, acted?: false},
      %{name: "Enemy", action: nil, acted?: false}
    ]

    {:ok,
     assign(socket,
       scene: "You are in a dark forest...",
       characters: characters,
       current_actor: nil,
       turn: 1
     )}
  end

  # Selecting a character
  def handle_event("select_character", %{"name" => name}, socket) do
    char = Enum.find(socket.assigns.characters, fn c -> c.name == name end)

    if char.acted? do
      # Undo action if clicked again
      characters =
        Enum.map(socket.assigns.characters, fn c ->
          if c.name == name, do: %{c | acted?: false, action: nil}, else: c
        end)

      {:noreply, assign(socket, characters: characters, current_actor: name)}
    else
      {:noreply, assign(socket, current_actor: name)}
    end
  end

  # Sending an action
  def handle_event("send_action", %{"action" => action}, socket) do
    current_actor = socket.assigns.current_actor

    # Mark current actor as acted
    characters =
      Enum.map(socket.assigns.characters, fn char ->
        if char.name == current_actor do
          %{char | action: action, acted?: true}
        else
          char
        end
      end)

    # Find the next character who hasn't acted
    next_actor =
      characters
      |> Enum.find(fn c -> not c.acted? end)
      |> case do
        nil -> nil   # all acted
        char -> char.name
      end

    socket = assign(socket, characters: characters, current_actor: next_actor)

    # If all acted, consolidate turn
    if next_actor == nil do
      actions_summary =
        characters
        |> Enum.map(fn c -> "🎭 <strong>#{c.name}</strong> acts: #{c.action}" end)
        |> Enum.join("<br>")

      new_scene =
        socket.assigns.scene <>
          "<br><br><strong>Turn #{socket.assigns.turn} actions:</strong><br>" <>
          actions_summary <>
          "<br><br>{this is a demo and gemini is not hooked yet... please wait patiently}"

      # Reset characters for next turn
      characters_reset =
        Enum.map(characters, fn c -> %{c | acted?: false, action: nil} end)

      {:noreply,
      assign(socket,
        characters: characters_reset,
        scene: new_scene,
        turn: socket.assigns.turn + 1,
        current_actor: nil  # no actor until next selection
      )}
    else
      {:noreply, socket}
    end
  end
end
