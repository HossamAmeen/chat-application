require 'rails_helper'

RSpec.describe 'Messages API', type: :request do
  let!(:application) { Application.create!(name: 'Test App', token: 'token123') }
  let!(:chat) { Chat.create!(application: application, number: 1) }
  let!(:message) { Message.create!(chat: chat, number: 1, body: 'Hello World') }

  describe 'GET /applications/:application_token/chats/:number/messages' do
    before { get "/applications/#{application.token}/chats/#{chat.number}/messages" }

    it 'returns a list of messages for the chat' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      expect(JSON.parse(response.body).first['body']).to eq('Hello World')
    end
  end

  describe 'POST /applications/:application_token/chats/:number/messages' do
    let(:application) { Application.create!(name: 'Test App', token: 'token123') }
    let(:chat) { application.chats.create!(number: 1) }
    let(:valid_attributes) { { message: { body: 'Hello, World!' } } }
  
    context 'when the request is valid' do
      before { post "/applications/#{application.token}/chats/#{chat.number}/messages", params: valid_attributes }
  
      it 'creates a new message' do
        expect(response).to have_http_status(:created)
        expect(json['body']).to eq('Hello, World!')
        expect(Message.find_by(body: 'Hello, World!')).to be_present
      end
    end
  
    context 'when the request is invalid' do
      let(:invalid_attributes) { { message: { body: '' } } }
  
      before { post "/applications/#{application.token}/chats/#{chat.number}/messages", params: invalid_attributes }
  
      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end  
end
