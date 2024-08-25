class MessagesController < ApplicationController
  before_action :set_application, only: [:index, :show, :update]
  before_action :set_chat, only: [:index, :show, :update]
  before_action :set_message, only: [:show, :update]

  def index
    @messages = @chat.messages
    render json: @messages
  end

  def show
    render json: @message
  end

  def create
    redis_key = "chat_#{params[:chat_number]}_messages_count"

    # Check if the message count exists in Redis
    messages_count = $redis.get(redis_key).to_i

    if messages_count.zero?
      @application = Application.find_by!(token: params[:application_token])
      @chat = @application.chats.find_by!(number: params[:chat_number])
      messages_count = @chat.messages_count
      $redis.set(redis_key, @chat.messages_count)
    end

    CreateMessageJob.perform_later(params[:application_token], params[:chat_number], params[:body])
    
    render json: {number: messages_count + 1}, status: :accepted

  end

  def update
    if @message.update(message_params)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def search
    query = params[:q]
    if query.present?
      @messages = Message.search({
        query: {
          bool: {
            must: [
              { match: { body: query } },
              { term: { chat_id: @chat.id } }
            ]
          }
        }
      }).records
      render json: @messages
    else
      render json: { error: 'Query parameter is missing' }, status: :bad_request
    end
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token])
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:chat_number])
  end

  def set_message
    @message = @chat.messages.find_by!(number: params[:number])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
