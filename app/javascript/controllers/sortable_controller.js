import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      onEnd: this.updatePositions.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  async updatePositions() {
    const ids = [...this.element.querySelectorAll("[data-project-id]")]
      .map(el => el.dataset.projectId)

    const token = document.querySelector('meta[name="csrf-token"]')?.content

    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || ""
      },
      body: JSON.stringify({ project_ids: ids })
    })
  }
}
