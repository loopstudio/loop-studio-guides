require 'rails_helper'
include 'session_helper'

RSpec.describe 'PUT /api/v1/users/:id', type: :request do
  let!(:user) { create(:user, :admin) }

  context 'when the user is logged in' do
    context 'when the user exists' do
      subject(:put_request) do
        put api_v1_users_path(user.id), params: params, headers: auth_headers
      end

      let(:new_name) { 'New Name' }
      let(:new_email) { 'new@email.com' }

      let(:params) do
        {
          id: user.id,
          name: new_name,
          email: new_email
        }
      end

      specify do
        put_request

        expect(response).to have_http_status(:success)
      end

      it 'returns the user information' do
        put_request

        user.reload
        expect(json[:users]).to include_json(
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at.strftime(EXPECTED_DATE_FORMAT)
        )
      end

      it 'updates the user' do
        put_request

        user.reload
        expect(user.name).to eq(new_name)
        expect(user.email).to eq(new_email)
      end

      context 'with an invalid email' do
        before { params[:email] = 'not_an_email' }

        specify do
          put_request

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the user is not authorized' do
        before { current_user.update_column(admin: false) }

        include_examples 'not authorized examples'
      end
    end

    context 'when the user does not exist' do
      subject(:not_found_request) do
        put api_v1_users_path(0), headers: auth_headers
      end

      specify do
        not_found_request

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'when the user is not logged in' do
    subject(:not_logged_in_request) do
      put api_v1_users_path(0)
    end

    include_examples 'not logged in examples'
  end
end
