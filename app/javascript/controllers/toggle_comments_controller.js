import { Controller } from "@hotwired/stimulus"

// Toggles hidden comments visibility
export default class extends Controller {
  toggle(event) {
    event.preventDefault()
    const hidden = document.getElementById("comments-hidden")
    if (hidden) {
      const isVisible = hidden.style.display !== "none"
      hidden.style.display = isVisible ? "none" : "block"
      this.element.textContent = isVisible ? this.element.dataset.showText || "See all comments ›" : this.element.dataset.hideText || "Hide comments ›"
    }
  }
}
