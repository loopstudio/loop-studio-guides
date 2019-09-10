require 'rails_helper'

RSpec.describe Logging::NotificationCreatorJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_now(user) }

  let(:user) { create(:user) }

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  context 'when the user is activated' do
    before do
      user.activate!
    end

    it 'broadcasts the notification to the recipient' do
      expect(Logging::NotificationService).to receive(:new)
        .with(user: user, object: object, action: action)
        .and_call_original

      expect_any_instance_of(Logging::NotificationService).to receive(:perform)

      job
    end
  end
end
