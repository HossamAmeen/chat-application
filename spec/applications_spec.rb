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
    let(:valid_attributes) { { name: 'New App' } }

    context 'when the request is valid' do
      before { post '/applications', params: valid_attributes }

      it 'creates a new application' do
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('New App')
      end
    end
  end
end
