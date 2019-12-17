require 'rails_helper'

RSpec.describe 'GET /api/v1/users', type: :request do
  let!(:user) { create(:user, :admin) }
  let(:expected_users) { create_list(:user, 3) }

  context 'when the user is logged in' do
    subject(:get_request) do
      get api_v1_users_path, headers: auth_headers
    end

    specify do
      get_request

      expect(response).to have_http_status(:success)
    end

    it 'includes the requested users' do
      get_request

      expected_users.each do |user|
        expect(json[:users]).to include_json(
          id: user.id,
          name: user.name,
          email: user.email
        )
      end
    end
  end

  context 'when the user is not logged in' do
    subject(:not_logged_in_request) do
      get api_v1_users_path
    end

    include_examples 'not logged in examples'
  end
end
