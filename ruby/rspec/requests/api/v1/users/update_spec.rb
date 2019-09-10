require 'rails_helper'
include 'session_helper'

RSpec.describe 'API::V1::Users requests', type: :request do
  let(:name)  { 'John' }
  let(:email)  { 'john@test' }
  let!(:user) { create(:user, name: name, email: email) }
  let!(:current_user) { create(:user, admin: true) }

  describe 'PATCH #show' do
    context 'when the user is logged in' do
      context 'when the user exists' do
        subject(:patch_request) do
          patch api_v1_users_path(user.id), params: new_attributes, headers: auth_headers(current_user)
        end

        let(:new_attributes) do
          {
            id: user.id,
            name: 'New Name',
            email: 'newmail@test',
          }
        end

        specify do
          patch_request

          expect(response).to have_http_status(:success)
        end

        expected_response = { data: { attributes: new_attributes } }
        expect(json['entities']['users']).to include_json(expected_response)

        context 'when the new data is invalid' do
          before { new_attributes.merge!(email: 'invalid_mail') }

          specify do
            post_request

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
          patch api_v1_users_path(0), headers: auth_headers(current_user)
        end

        specify do
          not_found_request

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is not logged in' do
      subject(:not_logged_in_request) do
        patch api_v1_users_path(0)
      end

      include_examples 'not logged in examples'
    end
  end
end
