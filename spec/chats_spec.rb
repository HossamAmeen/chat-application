require 'rails_helper'

RSpec.describe 'Chats API', type: :request do
  let!(:application) { Application.create!(name: 'Test App', token: 'token123') }
  let!(:chat) { Chat.create!(application: application, number: 1) }

  describe 'GET /applications/:application_token/chats' do
    before { get "/applications/#{application.token}/chats" }

    it 'returns a list of chats for the application' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      expect(JSON.parse(response.body).first['number']).to eq(1)
    end
  end

  describe 'POST /applications/:application_token/chats' do
    let(:valid_attributes) {}
    context 'when the request is valid' do
      before do
        post "/applications/#{application.token}/chats", params: valid_attributes
        application.reload  # Reload the application to get updated attributes
      end

      it 'creates a new chat' do
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['number']).to eq(2)
      end

      it 'updates chats_count in the application' do
        expect(application.chats_count).to eq(2)
      end
    end
  end
end
