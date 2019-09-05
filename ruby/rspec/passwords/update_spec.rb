require 'rails_helper'
require 'addressable/uri'

describe 'PUT api/v1/users/passwords/', type: :request do
  subject(:put_request) do
    put api_user_password_path, params: params, headers: headers, as: :json
  end

  let(:user)            { create(:user) }
  let!(:password_token) { user.send(:set_reset_password_token) }

  let(:new_password) { '123456789' }
  let(:params) do
    {
      password: new_password,
      password_confirmation: new_password
    }
  end

  context 'when the email link has the redirection headers' do
    let(:headers) do
      params = {
        reset_password_token: password_token,
        redirect_url: ENV.fetch('PASSWORD_RESET_URL', 'https://localhost:3000/')
      }
      get edit_api_user_password_path, params: params, headers: auth_headers
      edit_response_params = Addressable::URI.parse(response.header['Location']).query_values
      {
        'access-token' => edit_response_params['token'],
        'uid' => edit_response_params['uid'],
        'client' => edit_response_params['client_id']
      }
    end

    context 'when passing valid params' do
      it 'returns a successful response' do
        put_request

        expect(response).to be_successful
      end

      it 'updates the user password' do
        expect {
          put_request
        }.to change { user.reload.encrypted_password }
      end

      it 'makes the new password valid' do
        put_request

        expect(user.reload.valid_password?(new_password)).to eq(true)
      end
    end

    context 'when the password confirmation does not match' do
      let(:params) do
        {
          password: new_password,
          password_confirmation: 'wrongConfirmation'
        }
      end

      specify do
        put_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not change the user password' do
        expect {
          put_request
        }.to_not change(user.reload, :encrypted_password)
      end

      it 'does not make the new password valid' do
        put_request

        expect(user.reload.valid_password?(new_password)).to_not be
      end
    end
  end

  context 'when the email link has invalid redirection headers' do
    let(:headers) do
      {
        'access-token' => 'wrong token',
        'uid' => user.uid,
        'client' => 'some client'
      }
    end

    specify do
      put_request

      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not change the user password' do
      expect {
        put_request
      }.to_not change(user.reload, :encrypted_password)
    end

    it 'does not make the new password valid' do
      put_request

      expect(user.reload.valid_password?(new_password)).to_not be
    end
  end
end
