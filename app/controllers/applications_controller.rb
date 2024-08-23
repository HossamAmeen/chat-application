class ApplicationsController < ApplicationController
    before_action :set_application, only: [:show, :update]
  
    def index
      @applications = Application.all
      render json: @applications
    end
  
    def show
      render json: @application
    end
  
    def create
      @application = Application.new(application_params)
      @application.token = SecureRandom.hex(10)
      if @application.save
        render json: { token: @application.token }, status: :created
      else
        render json: @application.errors, status: :unprocessable_entity
      end
    end
  
    def update
      if @application.update(application_params)
        render json: @application
      else
        render json: @application.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_application
      @application = Application.find_by!(token: params[:token])
    end
  
    def application_params
      params.require(:application).permit(:name)
    end
  end
  