import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const params = new URLSearchParams(window.location.search)
    const urlTab = params.get("tab")
    const storedTab = localStorage.getItem("manager_active_tab")
    this._show(urlTab || storedTab || "attendees", false)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    localStorage.setItem("manager_active_tab", tab)
    this._show(tab, true)
  }

  _show(tab, animate) {
    this._current = tab
    this.tabTargets.forEach(el => {
      el.classList.toggle("tab-active", el.dataset.tab === tab)
    })
    if (!animate) {
      this.panelTargets.forEach(el => {
        const active = el.dataset.tab === tab
        el.classList.toggle("hidden", !active)
        el.classList.toggle("opacity-0", !active)
        el.classList.toggle("translate-y-2", !active)
        el.classList.toggle("opacity-100", active)
        el.classList.toggle("translate-y-0", active)
      })
      return
    }
    // Step 1: fade out current panel first
    this.panelTargets.forEach(el => {
      if (el.dataset.tab !== tab) {
        el.classList.remove("opacity-100", "translate-y-0")
        el.classList.add("opacity-0", "translate-y-2")
      }
    })
    // Step 2: after fade-out, hide old and reveal new
    setTimeout(() => {
      this.panelTargets.forEach(el => {
        const active = el.dataset.tab === tab
        if (active) {
          el.classList.remove("hidden")
          el.offsetHeight // force reflow
          el.classList.remove("opacity-0", "translate-y-2")
          el.classList.add("opacity-100", "translate-y-0")
        } else {
          el.classList.add("hidden")
        }
      })
    }, 200)
  }
}
