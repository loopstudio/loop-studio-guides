require 'rails_helper'

RSpec.describe 'POST /api/v1/users', type: :request do
  let!(:current_user) { create(:user, admin: true) }
  let(:params) { name: 'Alice', email: 'alice@test' }

  context 'when the user is logged in' do
    subject(:post_request) do
      post api_v1_users_path, params: params, headers: auth_headers
    end

    specify do
      post_request

      expect(response).to have_http_status(:success)
    end

    it 'creates a user' do
      expect {
        post_request
      }.to change(User, :count).by(1)
    end

    it 'returns the new user information' do
      post_request

      expected_response = {
        data: {
          attributes: params
        }
      }
      expect(json['entities']['users']).to include_json(expected_response)
    end

    context 'when the user is invalid' do
      let(:params) { }

      specify do
        post_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a user' do
        expect {
          post_request
        }.to_not change(User, :count)
      end
    end

    context 'when the user is not authorized' do
      before { current_user.update_column(admin: false) }

      include_examples 'not authorized examples'
    end
  end

  context 'when the user is not logged in' do
    subject(:not_logged_in_request) do
      post api_v1_users_path
    end

    include_examples 'not logged in examples'
  end
end
