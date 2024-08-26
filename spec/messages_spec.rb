require 'rails_helper'

RSpec.describe "Messages API", type: :request do
  let(:application) { Application.create!(name: 'Test App', token: 'token123')  }
  let(:chat) { Chat.create!(application: application, number: 1) }
  let(:message) { Message.create!(chat: chat, number: 1, body: 'Hello World') }
  let(:redis_key) { "chat_#{chat.number}_messages_count" }

  before do
    allow($redis).to receive(:get).and_return(nil)
    allow($redis).to receive(:set)
    allow(CreateMessageJob).to receive(:perform_later)
  end

  describe 'GET /applications/:application_token/chats/:chat_number/messages' do
    it 'returns all messages for the chat' do
      get "/applications/#{application.token}/chats/#{chat.number}/messages"

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /applications/:application_token/chats/:chat_number/messages' do
    context 'with valid parameters' do
      it 'creates a message and enqueues a job' do
        post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { body: 'Hello world' }

        expect(response).to have_http_status(:accepted)
        expect(CreateMessageJob).to have_received(:perform_later).with(application.token, chat.number.to_i, 'Hello world')
      end
    end

    context 'with missing body' do
      it 'returns an error' do
        post "/applications/#{application.token}/chats/#{chat.number}/messages", params: { body: '' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Body can't be blank")
      end
    end
  end

  describe 'PUT /applications/:application_token/chats/:chat_number/messages/:number' do
    context 'with valid parameters' do
      it 'updates the message' do
        put "/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", params: { message: { body: 'Updated body' } }

        expect(response).to have_http_status(:ok)
        expect(message.reload.body).to eq('Updated body')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error' do
        put "/applications/#{application.token}/chats/#{chat.number}/messages/#{message.number}", params: { message: { body: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("body" => ["can't be blank"])
      end
    end
  end

  describe 'GET /applications/:application_token/chats/:chat_number/messages/search' do
    it 'returns messages matching the query' do
      allow(Message).to receive(:search).and_return([message])
      get "/applications/#{application.token}/chats/#{chat.number}/messages/search", params: { q: 'Hello' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it 'returns an error when query is missing' do
      get "/applications/#{application.token}/chats/#{chat.number}/messages/search"

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include('error' => 'Query parameter is missing')
    end
  end
end
