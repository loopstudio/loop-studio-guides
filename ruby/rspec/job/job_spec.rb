require 'rails_helper'

RSpec.describe NotificationCreatorJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_now(user) }

  let(:user) { create(:user) }

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'broadcasts the notification to the recipient' do
    expect(NotificationService).to receive(:new).with(user).and_call_original
    expect_any_instance_of(NotificationService).to receive(:perform)

    job
  end
end
