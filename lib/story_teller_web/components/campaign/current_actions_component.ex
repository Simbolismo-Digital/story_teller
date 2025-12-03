defmodule StoryTellerWeb.Campaign.CurrentActionsComponent do
  use StoryTellerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 text-white p-6 h-[30vh] rounded-lg flex flex-col gap-1 overflow-auto">
      <h3 class="font-semibold mb-2">Current Actions:</h3>
      <ul class="flex-1 flex flex-col justify-start gap-1">
        <%= for char <- @characters do %>
          <li>
            <%= if char.action && String.trim(char.action) != "" do %>
              🎭 <b>{char.name}</b>: <span class="whitespace-pre-line">{char.action}</span>
            <% else %>
              ⌛ <b>{char.name}</b> is waiting
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
