require 'rails_helper'

describe 'GET /api/v1/auth/password/edit', type: :request do
  subject(:get_request) do
    get edit_api_user_password_path, params: params
  end

  let!(:user) { create(:user) }
  let(:password_token) { user.send(:set_reset_password_token) }
  let(:params) do
    {
      reset_password_token: password_token,
      redirect_url: ENV.fetch('PASSWORD_RESET_URL', 'https://localhost:3000/')
    }
  end

  it 'returns a the access token, uid and client id' do
    get_request

    expect(response.header['Location']).to include('token')
    expect(response.header['Location']).to include('uid')
    expect(response.header['Location']).to include('client_id')
  end
end
