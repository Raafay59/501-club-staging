import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "fallback"]

  handleError(event) {
    const image = this.hasImageTarget ? this.imageTarget : event.target
    image.classList.add("hidden")

    if (this.hasFallbackTarget) {
      this.fallbackTarget.classList.remove("hidden")
    }
  }
}
