require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  context 'with invalid token' do
    it 'connects and sets the current user' do
      connect '/cable', params: user.create_new_auth_token

      expect(connection.current_api_user.id).to eq(user.id)
    end
  end

  context 'with missing token' do
    it { expect { connect '/cable' }.to have_rejected_connection }
  end
end