import { Controller } from "@hotwired/stimulus"
import ChatChannel from "channels/chat_channel"

export default class extends Controller {
  connect() {
    this.open = false
    this.panel = this.element.querySelector(".chat-widget__panel")
    this.subscription = null

    this.boundFrameLoad = (event) => this.onFrameLoad(event)
    this.element.addEventListener("turbo:frame-load", this.boundFrameLoad)
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.boundFrameLoad)
    this.subscription?.unsubscribe()
  }

  toggle() {
    this.open = !this.open
    this.panel.classList.toggle("hidden", !this.open)
    this.element.classList.toggle("chat-widget--open", this.open)
  }

  onFrameLoad(event) {
    const frame = event.target
    const conversationId = frame.dataset.conversationId
    if (!conversationId || this.subscription) return

    this.subscription = ChatChannel.subscribe(
      parseInt(conversationId),
      frame.dataset.thinkingDomId,
      frame.dataset.messagesDomId
    )
  }
}
