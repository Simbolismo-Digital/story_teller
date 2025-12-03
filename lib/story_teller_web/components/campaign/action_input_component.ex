defmodule StoryTellerWeb.Campaign.ActionInputComponent do
  use StoryTellerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 text-white p-4 flex flex-col gap-2">
      <p>Enter action for <strong><%= @current_actor[:name] %></strong>:</p>
      <form
        id={"action-input-form-#{@current_actor[:name]}"}
        phx-hook="AutoFocus"
        phx-submit="send_action"
        class="flex gap-2 w-full"
      >
        <.input
          id={"action-input-#{@current_actor[:name]}"}
          name="action"
          class="flex-1 p-2 rounded bg-gray-800 text-white h-32 resize-none"
          placeholder="Action..."
          phx-hook="ActionInput"
          autocomplete="off"
          value={@current_actor[:action] || ""}
          type="textarea"
        />
        <button
          type="submit"
          class="bg-blue-600 px-4 rounded text-white"
          data-tip="Enter a valid action <shift + enter>"
          disabled
        >
          Send
        </button>
      </form>
    </div>
    """
  end
end
