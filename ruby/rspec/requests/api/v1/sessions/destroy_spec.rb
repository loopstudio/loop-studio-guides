require 'rails_helper'

describe 'DELETE /api/v1/auth/sign_out', type: :request do
  let(:user) { create(:user) }

  context 'when the user is logged in' do
    subject(:delete_request) do
      delete destroy_api_user_session_path, headers: auth_headers, as: :json
    end

    let(:access_token) { auth_headers['access-token'] }
    let(:client) { auth_headers['client'] }

    specify do
      delete_request

      expect(response).to have_http_status(:success)
    end

    it 'destroys the user token' do
      expect {
        delete_request
      }.to change { user.reload.valid_token?(access_token, client) }.from(true).to(false)
    end
  end

  context 'when the user is not logged in' do
    subject(:not_logged_in_request) do
      delete destroy_api_user_session_path, as: :json
    end

    specify do
      not_logged_in_request

      expect(response).to have_http_status(:not_found)
    end
  end
end
