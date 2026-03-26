import { Controller } from "@hotwired/stimulus"
import Tribute from "tributejs"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.loadEmojis()
  }

  disconnect() {
    if (this.tribute) {
      this.tribute.detach(this.inputTarget)
    }
  }

  async loadEmojis() {
    try {
      const response = await fetch("/admin/emojis.json")
      const emojis = await response.json()

      const values = Object.entries(emojis).map(([ key, value ]) => ({
        key,
        value: `${key}:`,
        display: `${value} ${key}`
      }))

      this.tribute = new Tribute({
        trigger: ":",
        values,
        lookup: "key",
        fillAttr: "value",
        menuItemTemplate: (item) =>
          `<span class="tribute-emoji">${item.original.display}</span>`,
        noMatchTemplate: () => null,
        requireLeadingSpace: false
      })

      this.tribute.attach(this.inputTarget)
    } catch (e) {
      console.error("Failed to load emojis for autocomplete", e)
    }
  }
}
