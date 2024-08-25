class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(application_token, chat_number, message_body)
    application = Application.find_by!(token: application_token)
    chat = application.chats.find_by!(number: chat_number)
    redis_key = "chat_#{chat_number}_messages_count"
    chat.messages.create!(body: message_body, number: $redis.incr(redis_key))

    
  end
end