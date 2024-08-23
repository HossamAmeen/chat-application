class ChatsController < ApplicationController
    before_action :set_application
    before_action :set_chat, only: [:show]
  
    def index
      @chats = @application.chats
      render json: @chats
    end
  
    def show
      render json: @chat
    end
  
    def create
      last_chat = @application.chats.order(:number).last
      new_number = last_chat ? last_chat.number + 1 : 1

    @chat = @application.chats.new(number: new_number)

      if @chat.save
        render json: { number: @chat.number }, status: :created
      else
        render json: @chat.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_application
      @application = Application.find_by(token: params[:application_token])
      render json: { error: 'Application not found' }, status: :not_found unless @application
    end
  
    def set_chat
      @chat = @application.chats.find_by!(number: params[:number])
    end
  end
  