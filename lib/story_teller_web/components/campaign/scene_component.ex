defmodule StoryTellerWeb.Campaign.SceneComponent do
  use StoryTellerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex-1 bg-gray-800 text-white p-4 overflow-auto">
      <h2 class="text-xl font-bold mb-2">Scene</h2>
      <div id="scene-output" class="whitespace-pre-wrap">
        {raw(@scene)}
      </div>
    </div>
    """
  end
end
