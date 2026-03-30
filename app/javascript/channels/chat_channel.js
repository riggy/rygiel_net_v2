import consumer from "channels/consumer"

const ChatChannel = {
  subscribe(conversationId, thinkingId, messagesId) {
    return consumer.subscriptions.create(
      { channel: "ChatChannel", conversation_id: conversationId },
      {
        received(data) {
          if (data.event !== "message_created") return

          const thinking = document.getElementById(thinkingId)
          if (thinking) thinking.remove()

          const list = document.getElementById(messagesId)
          if (list) {
            list.insertAdjacentHTML("beforeend", data.html)
            list.lastElementChild?.scrollIntoView({ behavior: "smooth" })
          }
        }
      }
    )
  }
}

export default ChatChannel
