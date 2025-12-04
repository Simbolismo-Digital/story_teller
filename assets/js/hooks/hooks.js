import YoutubePlayerHook from "./youtube_player_hook";

let Hooks = {}

Hooks.YoutubePlayer = YoutubePlayerHook;

// Any
Hooks.AutoFocus = {
  mounted() {
    this.el.focus()
  },
  updated() {
    this.el.focus()
  }
}

// Campaigns
Hooks.ActionInput = {
  mounted() {
    const textarea = this.el
    const form = textarea.closest("form")
    if (!form) return

    const button = form.querySelector('button[type="submit"]')

    // ensure button starts disabled if button exists
    if (button) button.disabled = textarea.value.trim() === ""

    textarea.focus()

    textarea.addEventListener("input", () => {
      // only update button if it exists
      if (button) button.disabled = textarea.value.trim() === ""
    })

    textarea.addEventListener("keydown", (e) => {
      // SHIFT + ENTER → submit form
      if (e.key === "Enter" && e.shiftKey) {
        e.preventDefault()

        // only submit if textarea has value
        if (textarea.value.trim() !== "") {
          form.dispatchEvent(new Event("submit", { bubbles: true }))
        }
      }
    })
  }
}

export default Hooks