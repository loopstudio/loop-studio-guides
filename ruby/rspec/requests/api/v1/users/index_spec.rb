require 'rails_helper'
include 'session_helper'

RSpec.describe 'API::V1::Users requests', type: :request do
  let!(:current_user) { create(:user, admin: true) }
  let(:users) do
    [
      create(:user, id: 1, name: 'John', email: 'john@test'),
      create(:user, id: 2, name: 'Alice', email: 'alice@test'),
      create(:user, id: 3, name: 'Bob', email: 'bob@test')
    ]
  end

  describe 'GET #index' do
    context 'when the user is logged in' do
      subject(:get_request) do
        get api_v1_users_path, headers: auth_headers(current_user)
      end

      specify do
        get_request

        expect(response).to have_http_status(:success)
      end

      it 'includes all the users' do
        get_request

        expected_response = {
          data: [
            { id: 1 },
            { id: 2 },
            { id: 3 }
          ]
        }
        expect(json['entities']['users']).to include_json(expected_response)
      end
    end

    context 'when the user is not logged in' do
      subject(:not_logged_in_request) do
        get api_v1_users_path
      end

      include_examples 'not logged in examples'
    end
  end
end
