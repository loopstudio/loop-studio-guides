require 'rails_helper'

RSpec.describe NotificationService, type: :service do
  describe '#perform' do
    subject(:perform) do
      described_class.new(user: user, object: object, url: url).perform
    end

    let(:url) { FFaker::InternetSE.http_url }
    let(:user) { create(:user) }
    let(:object) { create(:tagging) }

    let(:created_notification) { Notification.last }
    let(:expected_text) { "You've been tagged" }

    it 'creates a notification record' do
      expect {
        perform
      }.to change(Notification, :count).by(1)

      expect(created_notification.text).to eq(expected_text)
      expect(created_notification.url).to eq(url)
    end

    it 'assigns the correct user id to the notification' do
      perform

      expect(created_notification.user_id).to eq(user.id)
    end

    it 'enqueues a notification relay job' do
      expect {
        perform
      }.to have_enqueued_job(NotificationRelayJob)
        .exactly(:once)
        .with(an_instance_of(Notification), an_instance_of(User))
    end

    it 'defaults to low priority' do
      perform

      expect(created_notification.priority).to eq('high')
    end

    context 'when a priority is given' do
      subject(:perform) do
        described_class.new(object: object,
                            url: url,
                            user: user,
                            priority: 'high').perform
      end

      it 'assigns the given priority' do
        perform

        expect(created_notification.priority).to eq('high')
      end
    end
  end
end
