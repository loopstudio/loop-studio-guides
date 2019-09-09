require 'rails_helper'

describe 'POST api/v1/users/sign_in', type: :request do
  subject(:post_request) do
    post new_api_user_session_path, params: params, as: :json
  end

  let(:password) { 'password' }
  let!(:user) do
    create(:user,
            password: password,
            password_confirmation: password)
  end

  context 'when passing correct params' do
    let(:params) do
      {
        user:
          {
            email: user.email,
            password: password
          }
      }
    end

    specify do
      post_request

      expect(response).to be_success
    end

    it 'returns the user' do
      post_request

      expect(json[:user][:id]).to eq(user.id)
      expect(json[:user][:email]).to eq(user.email)
      expect(json[:user][:first_name]).to eq(user.first_name)
      expect(json[:user][:last_name]).to eq(user.last_name)
    end

    it 'returns a valid client and access token' do
      post_request

      token = response.header['access-token']
      client = response.header['client']
      expect(user.reload.valid_token?(token, client)).to be_truthy
    end
  end

  context 'when the password is invalid' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: 'wrong_password'
        }
      }
    end

    specify do
      post_request

      expect(response).to be_unauthorized
    end
  end

  context 'when the email is invalid' do
    let(:params) do
      {
        user: {
          email: 'wrong@email.com',
          password: user.password
        }
      }
    end

    specify do
      post_request

      expect(response).to be_unauthorized
    end
  end
end
