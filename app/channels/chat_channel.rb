class ChatChannel < ActionCable::Channel::Base
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id].to_i)
    conversation ? stream_from(conversation.channel_name) : reject
  end
end
