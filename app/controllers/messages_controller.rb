class MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat
  before_action :set_message, only: [:show, :update]

  def index
    @messages = @chat.messages
    render json: @messages
  end

  def show
    render json: @message
  end

  def create
    new_number = @chat.messages.count + 1
    @message = @chat.messages.new(message_params.merge(number: new_number))

    if @message.save
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
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
