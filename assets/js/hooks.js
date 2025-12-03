let Hooks = {}

Hooks.FocusInput = {
  mounted() {
    this.el.focus()
  },
  updated() {
    this.el.focus()
  }
}

export default Hooks