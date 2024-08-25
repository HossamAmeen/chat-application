RSpec.describe 'Messages API', type: :request do
  let!(:application) { Application.create!(name: 'Test App', token: 'token123') }
  let!(:chat) { Chat.create!(application: application, number: 1) }
  let!(:message) { Message.create!(chat: chat, number: 1, body: 'Hello World') }

  describe 'GET /applications/:application_token/chats/:number/messages' do
    before { get "/applications/#{application.token}/chats/#{chat.number}/messages" }

    it 'returns a list of messages for the chat' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
    end
  end

  describe 'POST /applications/:application_token/chats/:number/messages' do
    context 'when the request is valid' do
      let(:valid_attributes) { { message: { body: 'Hello, World!' } } }

      before { post "/applications/#{application.token}/chats/#{chat.number}/messages", params: valid_attributes.to_json, headers: { 'Content-Type': 'application/json' } }

      it 'creates a new message' do
        expect(response).to have_http_status(:accepted)
        expect(Message.find_by(body: 'Hello, World!')).to be_present
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { message: { body: '' } } }

      before { post "/applications/#{application.token}/chats/#{chat.number}/messages", params: invalid_attributes, as: :json }

      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end  
end
