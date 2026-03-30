import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.open = false
    this.panel = this.element.querySelector(".chat-widget__panel")
  }

  toggle() {
    this.open = !this.open
    this.panel.classList.toggle("hidden", !this.open)
    this.element.classList.toggle("chat-widget--open", this.open)
  }
}
