require 'rails_helper'

describe 'POST api/v1/users/passwords', type: :request do
  subject :post_request do
    post api_user_password_path, params: params, as: :json
  end

  let!(:user) { create(:user) }

  context 'when passing valid params' do
    let(:params) { { email: user.email } }

    specify do
      post_request

      expect(response).to have_http_status(:success)
    end

    it 'returns the user email' do
      post_request

      expect(json[:message]).to match(/#{user.email}/)
    end

    it 'sends an email to reset the password' do
      expect {
        post_request
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'changes the user password reset token' do
      expect {
        post_request
      }.to change { user.reload.reset_password_token }
    end
  end

  context 'when the email is invalid' do
    let(:params) { { email: 'wrong@email.com' } }

    specify do
      post_request

      expect(response).to have_http_status(:not_found)
    end

    it 'does not send an email' do
      expect {
        post_request
      }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
