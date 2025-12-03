defmodule StoryTellerWeb.Campaign.SidebarComponent do
  use StoryTellerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-64 bg-gray-700 text-white p-4 flex flex-col gap-2 overflow-auto">
      <h2 class="text-lg font-bold mb-2">Characters</h2>
      <%= for char <- @characters do %>
        <button
          phx-click="select_character"
          phx-value-name={char.name}
          class={"flex items-center justify-between p-2 rounded #{if @current_actor[:name] == char.name, do: "bg-gray-500", else: "hover:bg-gray-600"}"}
        >
          <span>{char.name}</span>
          <span>{if char.acted?, do: "🎭", else: "⌛"}</span>
        </button>
      <% end %>
    </div>
    """
  end
end
