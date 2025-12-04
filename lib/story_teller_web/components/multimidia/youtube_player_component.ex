defmodule StoryTellerWeb.Multimidia.YoutubePlayerComponent do
  use StoryTellerWeb, :html

  def youtube_player(assigns) do
    ~H"""
    <div class="flex items-center gap-2 text-white mx-4">
      <div class="flex-col w-full items-center gap-2 text-white mx-4">
        <div id="youtube-player-title" class="text-sm text-gray-300 max-w-xs text-center">
          <!-- title updated via Hook -->
          Loading...
        </div>
        <!-- Bottom row: progress bar -->
        <div class="relative w-full h-4 bg-gray-500 rounded overflow-hidden group mt-1">
          <div
            id="youtube-player-progress"
            class="absolute top-0 left-0 h-4 bg-green-500 rounded"
            style="width:0%"
          >
          </div>
          <div
            class="absolute inset-0 hidden group-hover:block text-xs text-white text-center pointer-events-none"
            id="youtube-player-progress-tooltip"
          >
            0:00
          </div>
        </div>
      </div>
      <button id="youtube-player-btn-prev" class="p-2 rounded hover:bg-gray-700" title="Previous">
        <!-- ícone anterior -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M11 19l-7-7 7-7M18 19l-7-7 7-7"
          />
        </svg>
      </button>

      <button id="youtube-player-btn-toggle" class="p-2 rounded hover:bg-gray-700" title="Play">
        <!-- ícone inicial: play -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="currentColor"
          viewBox="0 0 24 24"
          stroke="none"
        >
          <path d="M5 3v18l15-9L5 3z" />
        </svg>
      </button>

      <button id="youtube-player-btn-next" class="p-2 rounded hover:bg-gray-700" title="Next">
        <!-- ícone próximo -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 5l7 7-7 7M6 5l7 7-7 7"
          />
        </svg>
      </button>

      <button
        id="youtube-player-btn-loop"
        class="p-2 rounded hover:bg-gray-700 bg-gray-600"
        title="Loop"
      >
        <!-- ícone loop -->
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="h-8 w-8">
          <!-- Snake body, ~30% open -->
          <path
            d="M 2.00 32.00 C 2.00 14.00 20.00 2.00 32.00 2.00 C 44.00 2.00 62.00 14.00 62.00 32.00 C 62.00 50.00 44.00 62.00 32.00 62.00 C 20.00 62.00 2.00 50.00 18.00 32.00"
            fill="none"
            stroke="currentColor"
            stroke-width="4"
            stroke-linecap="round"
          />
          
    <!-- Aggressive snake head -->
          <path
            d="M 2.00 32.00 L -4.00 18.00 L 10.00 10.00 L 14.00 16.00 L 10.00 20.00 L 12.00 22.00 L 8.00 24.00 Z"
            fill="currentColor"
          />
          
    <!-- Fangs -->
          <path d="M 14.00 16.00 L 10.00 18.00 L 16.00 17.00 Z" fill="white" />
          <path d="M 10.00 20.00 L 12.00 22.00 L 16.00 21.00 Z" fill="white" />
          
    <!-- Eye -->
          <circle cx="4.0" cy="20.0" r="1.5" fill="white" />
        </svg>
      </button>
      
    <!-- New config button -->
      <button id="youtube-player-btn-config" class="p-2 rounded hover:bg-gray-700" title="Config">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="currentColor"
          class="h-6 w-6"
        >
          <!-- center circle -->
          <circle cx="12" cy="12" r="3" />
          <!-- gear outline with bottom cut -->
          <path d="M19.4 12a7.4 7.4 0 0 0-.1-1l2-1.6a.5.5 0 0 0 .1-.6l-2-3.5a.5.5 0 0 0-.6-.2l-2.5 1a7.3 7.3 0 0 0-1.7-1l-.4-2.7a.5.5 0 0 0-.5-.4h-4a.5.5 0 0 0-.5.4l-.4 2.7a7.3 7.3 0 0 0-1.7 1l-2.5-1a.5.5 0 0 0-.6.2l-2 3.5a.5.5 0 0 0 .1.6l2 1.6c-.05.3-.1.65-.1 1s.05.7.1 1l-2 1.6a.5.5 0 0 0-.1.6l2 3.5c.1.2.35.3.6.2l2.5-1c.5.4 1.1.75 1.7 1l.4 2.7c.05.25.25.4.5.4h4c.25 0 .45-.15.5-.4l.4-2.7c.6-.25 1.2-.6 1.7-1l2.5 1c.25.1.5 0 .6-.2l2-3.5a.5.5 0 0 0-.1-.6l-2-1.6zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8z" />
        </svg>
      </button>
      
    <!-- Config modal -->
      <div
        id="youtube-player-config-modal"
        class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50"
      >
        <div class="bg-gray-800 text-white p-6 rounded-lg w-96">
          <div class="flex items-center gap-2 mt-2 mb-2">
            <span class="text-white text-sm">
              <h2 class="text-xl font-bold">Autoplay</h2>
            </span>
            <label
              for="youtube-player-playlist-autoplay"
              class="relative inline-flex items-center cursor-pointer"
            >
              <input type="checkbox" id="youtube-player-playlist-autoplay" class="sr-only peer" />
              <div class="w-11 h-6 bg-gray-300 peer-focus:ring-2 peer-focus:ring-blue-500 rounded-full peer peer-checked:bg-blue-600 transition-all">
              </div>
              <span class="absolute left-0.5 top-0.5 bg-white w-5 h-5 rounded-full transition-transform peer-checked:translate-x-5">
              </span>
            </label>
          </div>

          <h2 class="text-xl font-bold mb-4">Manage Playlist</h2>

          <form id="playlist-form" class="flex gap-2 mb-4">
            <input
              type="text"
              id="youtube-player-playlist-input-new"
              placeholder="Video ID"
              class="flex-1 p-1 rounded text-black"
            />
            <button
              type="button"
              id="youtube-player-playlist-btn-add"
              class="px-3 py-1 bg-gray-700 rounded hover:bg-gray-600"
            >
              Add
            </button>
          </form>

          <ul id="youtube-player-playlist" class="mb-4">
            <!-- Items will be dynamically added via JS -->
          </ul>

          <button
            id="youtube-player-btn-config-close"
            class="mt-2 px-4 py-2 bg-gray-700 rounded hover:bg-gray-600"
          >
            Close
          </button>
        </div>
      </div>
      
    <!-- Player container invisible -->
      <div id="youtube-player" phx-hook="YoutubePlayer" class="absolute top-0 left-0 h-0 w-0"></div>
    </div>
    """
  end
end
