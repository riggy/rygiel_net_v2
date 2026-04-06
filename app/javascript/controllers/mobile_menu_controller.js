import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "open", "close"]

  toggle() {
    const hidden = this.menuTarget.classList.toggle("hidden")
    this.openTarget.classList.toggle("hidden", !hidden)
    this.closeTarget.classList.toggle("hidden", hidden)
  }
}
