import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.open = false
    this.panel = this.element.querySelector(".chat-widget__panel")
    this.observer = null

    this.element.addEventListener("turbo:frame-load", () => this.observeMessages())
  }

  disconnect() {
    this.observer?.disconnect()
  }

  toggle() {
    this.open = !this.open
    this.panel.classList.toggle("hidden", !this.open)
    this.element.classList.toggle("chat-widget--open", this.open)
  }

  observeMessages() {
    this.observer?.disconnect()
    const messages = this.element.querySelector(".chat-messages")
    if (!messages) return

    this.scrollToBottom(messages)
    this.observer = new MutationObserver(() => this.scrollToBottom(messages))
    this.observer.observe(messages, { childList: true })
  }

  scrollToBottom(el) {
    el.scrollTop = el.scrollHeight
  }
}
