require 'rails_helper'

RSpec.describe 'Applications API', type: :request do
  let!(:application) { Application.create!(name: 'Test App', token: 'token123') }

  describe 'GET /applications' do
    before { get '/applications' }

    it 'returns a list of applications' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      expect(JSON.parse(response.body).first['name']).to eq('Test App')
    end
  end

  describe 'POST /applications' do
    let(:valid_attributes) { { application: { name: 'New App' } } }
  
    context 'when the request is valid' do
      before { post '/applications', params: valid_attributes }
  
      it 'creates a new application' do
        expect(response).to have_http_status(:created)
        
        # Extract token from response
        response_body = json
        token = response_body['token']
  
        # Check that token is present in the database
        expect(token).not_to be_nil
        expect(Application.find_by(token: token)).to be_present
      end
    end
  
    context 'when the request is invalid' do
      let(:invalid_attributes) { { application: { name: '' } } }
  
      before { post '/applications', params: invalid_attributes }
  
      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
end
