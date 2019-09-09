require 'rails_helper'

describe 'DELETE api/v1/users/sign_out', type: :request do
  let(:user) { create(:user) }

  context 'when user is logged in' do
    subject(:delete_request) do
      delete destroy_api_user_session_path, headers: auth_headers, as: :json
    end

    let(:access_token) { auth_headers['access-token'] }
    let(:client) { auth_headers['client'] }

    it 'returns a successful response' do
      delete_request

      expect(response).to have_http_status(:success)
    end

    it 'destroys the user token' do
      expect {
        delete_request
      }.to change { user.reload.valid_token?(access_token, client) }.from(true).to(false)
    end
  end

  context 'when user is not logged in' do
    subject(:not_logged_in_request) do
      delete destroy_api_user_session_path, as: :json
    end

    it 'returns not found' do
      not_logged_in_request

      expect(response).to have_http_status(:not_found)
    end
  end
end
