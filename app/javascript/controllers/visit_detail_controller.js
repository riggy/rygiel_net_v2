import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const row = event.currentTarget.closest("tr")
    const detailRow = row.nextElementSibling
    if (detailRow) detailRow.classList.toggle("hidden")
  }
}
