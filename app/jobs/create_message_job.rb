class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(application_token, chat_number, message_body)
    application = Application.find_by!(token: application_token)
    chat = application.chats.find_by!(number: chat_number)

    # Create the message
    redis_key = "chat_#{chat_number}_messages_count"
    message = chat.messages.create!(body: message_body, number: $redis.incr(redis_key))

    # Index the message in Elasticsearch
    message.__elasticsearch__.index_document
  end
end
