require 'rails_helper'
include 'session_helper'

RSpec.describe 'API::V1::Users requests', type: :request do
  let(:name)  { 'John' }
  let(:email)  { 'john@test' }
  let!(:user) { create(:user, name: name, email: email) }
  let!(:current_user) { create(:user, admin: true) }

  describe 'GET #show' do
    context 'when the user is logged in' do
      context 'when the user exists' do
        subject(:get_request) do
          get api_v1_users_path(user.id), headers: auth_headers(current_user)
        end

        specify do
          get_request

          expect(response).to have_http_status(:success)
        end

        it 'includes the user information' do
          get_request

          expect(json['entities']['users']).to include_json(
            id: user.id,
            name: name,
            email: email,
            created_at: user.created_at.strftime(EXPECTED_DATE_FORMAT),
            updated_at: user.updated_at.strftime(EXPECTED_DATE_FORMAT)
          )
        end

        context 'when the user is not authorized' do
          before { current_user.update_column(admin: false) }

          include_examples 'not authorized examples'
        end
      end

      context 'when the user does not exist' do
        subject(:not_found_request) do
          get api_v1_users_path(0), headers: auth_headers(current_user)
        end

        specify do
          not_found_request

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not logged in' do
      subject(:not_logged_in_request) do
        get api_v1_users_path(0)
      end

      include_examples 'not logged in examples'
    end
  end
end
