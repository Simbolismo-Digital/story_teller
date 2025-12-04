import * as Youtube from "../apis/youtube_player.js";

const YoutubePlayerHook = {
  mounted() {
    // player state
    this.isPlaying = false;
    // initialize from localStorage
    this.autoPlay = (localStorage.getItem("youtubeAutoplay") || "true") === "true";
    this.autoPlayInterval = null;
    
    // only first autoplay
    if (this.autoPlay && !this.autoPlayInterval) {
      this.autoPlayInterval = setInterval(() => {
        Youtube?.playVideo();
      }, 500);
    }

    if (window.YT && window.YT.Player) {
      console.log("Loaded Youtube API...")
      this.initPlayer();
    } else {
      window.onYouTubeIframeAPIReady = function () {
        console.log("Initializing Youtube API..")
        this.initPlayer();
      };
    }

    // listen to global buttons
    document.getElementById("youtube-player-btn-toggle").addEventListener("click", () => {
      if (this.isPlaying) {
        Youtube.pauseVideo();
      } else {
        Youtube.playVideo();
      }
    });

    document.getElementById("youtube-player-btn-next").addEventListener("click", () => {
      Youtube.nextVideo();
    });

    document.getElementById("youtube-player-btn-prev").addEventListener("click", () => {
      Youtube.previousVideo();
    });

    const loopBtn = document.getElementById("youtube-player-btn-loop");
    document.getElementById("youtube-player-btn-loop").addEventListener("click", () => {
      const isLoop = Youtube.toggleLoop();
        if (isLoop) {
          loopBtn.classList.add("bg-gray-600");
        } else {
          loopBtn.classList.remove("bg-gray-600");
        }
    });

    // --- Config modal ---
    const modal = document.getElementById("youtube-player-config-modal");
    const configBtn = document.getElementById("youtube-player-btn-config");
    const closeBtn = document.getElementById("youtube-player-btn-config-close");
    const addBtn = document.getElementById("youtube-player-playlist-btn-add");
    const newInput = document.getElementById("youtube-player-playlist-input-new");
    const listEl = document.getElementById("youtube-player-playlist");
    const autoplayCheckbox = document.getElementById("youtube-player-playlist-autoplay");
    autoplayCheckbox.checked = this.autoPlay;

    // show modal
    configBtn.addEventListener("click", () => {
      modal.classList.remove("hidden");
      modal.classList.add("flex");
      this.renderPlaylist();
    });

    // hide modal
    closeBtn.addEventListener("click", () => {
      modal.classList.add("hidden");
      modal.classList.remove("flex");
    });

    // hide modal if clicking outside the content
    modal.addEventListener("click", (event) => {
      // only hide if clicked directly on the overlay (not children)
      if (event.target === modal) {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
      }
    });

    // listen to toggle
    autoplayCheckbox.addEventListener("change", (e) => {
      this.autoPlay = e.target.checked;
      localStorage.setItem("youtubeAutoplay", this.autoPlay);
      this.maybeAutoplay();
    });

    // add video
    addBtn.addEventListener("click", () => {
      const val = newInput.value.trim();
      if (!val) return;

      // split by comma or space
      const ids = val.split(/[\s,]+/).map(id => id.trim()).filter(id => id.length > 0);

      // validate all IDs
      const invalidIds = ids.filter(id => id.length !== 11);
      if (invalidIds.length > 0) {
        newInput.classList.add("border-red-500", "animate-pulse");
        setTimeout(() => {
          newInput.classList.remove("border-red-500", "animate-pulse");
        }, 500);
        return;
      }

      // all valid → merge with current playlist
      let playlist = localStorage.getItem("youtube-playlist") || "";
      let items = playlist ? playlist.split(",") : [];
      items.push(...ids);
      playlist = items.join(",");
      localStorage.setItem("youtube-playlist", playlist);

      newInput.value = "";
      this.renderPlaylist();
      Youtube.playLists(items);
    });

    // render playlist
    this.renderPlaylist = () => {
      const playlist = localStorage.getItem("youtube-playlist") || "";
      const items = playlist ? playlist.split(",") : [];
      listEl.innerHTML = "";

      items.forEach((vid, idx) => {
        const li = document.createElement("li");
        li.className = "flex justify-between items-center mb-1";
        li.innerHTML = `
          <span>${vid}</span>
          <button class="px-2 py-1 bg-red-600 rounded hover:bg-red-500">Remove</button>
        `;
        li.querySelector("button").addEventListener("click", () => {
          items.splice(idx, 1);
          const newPlaylist = items.join(",");
          localStorage.setItem("youtube-playlist", newPlaylist);
          this.renderPlaylist();
          Youtube.playLists(items);
        });
        listEl.appendChild(li);
      });
    };

    // Youtube Player Progress
    const progressEl = document.getElementById("youtube-player-progress");
    const tooltipEl = document.getElementById("youtube-player-progress-tooltip");
    const progressContainer = progressEl.parentElement;

    // Update progress every 250ms
    const interval = setInterval(() => {
      const current = Youtube.getCurrentTime();
      const duration = Youtube.getDuration();
      const percent = (current / duration) * 100;

      progressEl.style.width = `${percent}%`;
      tooltipEl.innerText = formatTime(current);
    }, 250);

    // Tooltip on hover
    progressContainer.addEventListener("mousemove", (e) => {
      const rect = progressContainer.getBoundingClientRect();
      const percent = (e.clientX - rect.left) / rect.width;
      const time = percent * Youtube.getDuration();
      tooltipEl.innerText = formatTime(time);
    });

    // Click to seek
    progressContainer.addEventListener("click", (e) => {
      const rect = progressContainer.getBoundingClientRect();
      const percent = (e.clientX - rect.left) / rect.width;
      Youtube.seekTo(percent, true);
    });

    // Time format
    function formatTime(seconds) {
      const m = Math.floor(seconds / 60);
      const s = Math.floor(seconds % 60);
      return `${m}:${s.toString().padStart(2, "0")}`;
    }

    // Cleanup on destroy
    this.destroy = () => clearInterval(interval);
  },
  initPlayer() {
    // Try to get playlist from localStorage
    let playlist = localStorage.getItem("youtube-playlist");

    // If nothing stored, initialize with default
    if (!playlist) {
      playlist = 'xt544bCPqAw,d9SCrpXN3EE,BF3wM5Onh6c';
      localStorage.setItem("youtube-playlist", playlist);
    }

    Youtube.initPlayer(playlist, (event, data) => {
      this.handlePlayerEvent(event, data);
    });
  },
  maybeAutoplay() {
    if (this.autoPlay && !this.autoPlayInterval) {
      this.autoPlayInterval = setInterval(() => {
        Youtube?.playVideo();
      }, 500);
    }
  },
  // Function inside the hook
  handlePlayerEvent(event, data) {
    switch(event) {
      case 'ready':
        console.log('Player ready, video id:', datavideoId);
        break;
      case 'playing':
        clearInterval(this.autoPlayInterval);
        console.log('Playing now:', data.title);
        this.updateToggleIcon(true);
        this.updateTitle(data.title);
        // Recupera estado salvo (index + tempo)
        const saved = JSON.parse(localStorage.getItem("youtube-player-track") || "{}");
        const mustResume = saved.index != null && saved.time != null;
        if (!this.hasResumed && mustResume) {
          if (Youtube.getPlaylistIndex() !== saved.index) {
            Youtube.playLists(window.Youtube.playlistIds, saved.index);
          } else {
            Youtube.seekToTime(saved.time);
            this.hasResumed = true;
          }
        } else {
          this.hasResumed = true;
        }
        if (this.hasResumed && !this.isSaving) {
          // Don't interfere imediately on load
          setTimeout(() => {
            // Save track interval
            setInterval(() => {
              const index = Youtube.getPlaylistIndex();
              if (index === null) return;
              const time = Youtube.getCurrentTime();
              localStorage.setItem("youtube-player-track", JSON.stringify({ index, time }));
            }, 1000);
          }, 5000);
          this.isSaving = true;
        }
        break;
      case 'ended':
        console.log('Video ended:', data.title);
        this.updateToggleIcon(false);
        break;
      case 'paused':
        console.log('Paused:', data.title);
        this.updateToggleIcon(false);
        break;
      case 'buffering':
        console.log('Buffering:', data.title);
        break;
      default:
        console.log('Event:', event, data);
    }
  },
  // Play/Pause
  updateToggleIcon(isPlaying) {
    this.isPlaying = isPlaying;
    const toggleBtn = document.getElementById("youtube-player-btn-toggle");
    if (!toggleBtn) return;

    toggleBtn.innerHTML = isPlaying
      ? `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" stroke="none">
          <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z"/>
        </svg>` // pause
      : `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" stroke="none">
          <path d="M5 3v18l15-9L5 3z"/>
        </svg>`; // play
  },
  // Another function to update the DOM
  updateTitle(title) {
    document.getElementById('youtube-player-title').innerText = title;
  }
};

window.Youtube = Youtube;

export default YoutubePlayerHook;