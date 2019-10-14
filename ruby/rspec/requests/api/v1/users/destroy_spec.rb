require 'rails_helper'
include 'session_helper'

RSpec.describe 'DELETE /api/v1/users/:id', type: :request do
  let(:user) { create(:user, :admin) }

  context 'when the user is logged in' do
    context 'when the user exists' do
      subject(:delete_request) do
        delete api_v1_users_path(user.id), headers: auth_headers
      end

      specify do
        delete_request

        expect(response).to have_http_status(:success)
      end

      it 'deletes the user' do
        expect {
          delete_request
        }.to change(User, :count).by(-1)
      end

      context 'when the user is not authorized' do
        before { current_user.update!(admin: false) }

        include_examples 'not authorized examples'
      end
    end

    context 'when the user does not exist' do
      subject(:not_found_request) do
        delete api_v1_users_path(0), headers: auth_headers
      end

      specify do
        not_found_request

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'when the user is not logged in' do
    subject(:not_logged_in_request) do
      delete api_v1_users_path(0)
    end

    include_examples 'not logged in examples'
  end
end
