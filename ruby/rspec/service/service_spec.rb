require 'rails_helper'

RSpec.describe Logging::NotificationService, type: :service do
  describe '#perform' do
    subject(:perform) do
      described_class.new(user: user, object: object, action: action, url: url).perform
    end

    let(:url) { FFaker::InternetSE.http_url }

    context 'when the notification is to a specific user' do
      let(:user) { create(:user) }
      let(:object) { create(:logging_tagging) }
      let(:action) { 'created' }
      let(:expected_text) { "You've been tagged" }

      it 'creates a notification record' do
        expect {
          perform
        }.to change(Logging::Notification, :count).by(1)

        notification = Logging::Notification.last
        expect(notification.text).to eq(expected_text)
        expect(notification.url).to eq(url)
        expect(notification.priority).to eq('low')
      end

      it 'assigns the correct user id to the notification' do
        perform

        notification = Logging::Notification.last
        expect(notification.user_id).to eq(user.id)
      end

      it 'enqueues a notification relay job' do
        expect {
          perform
        }.to have_enqueued_job(Logging::NotificationRelayJob)
          .exactly(:once)
          .with(an_instance_of(Logging::Notification), an_instance_of(User))
      end

      context 'when a priority is given' do
        perform(:perform) do
          described_class.new(object: object, action: action,
                              url: url, user: user, priority: 'high').perform
        end

        it 'assigns that priority' do
          perform

          notification = Logging::Notification.last
          expect(notification.priority).to eq('high')
        end
      end
    end

    context 'when the notification has many recipients' do
      let(:object)        { create(:proj_mgmt_project) }
      let(:action)        { 'created' }
      let(:expected_text) { 'New Project - Project' }

      context 'when the user is nil' do
        let(:user) { nil }

        let!(:team_user1)      { create(:user) }
        let!(:team_user2)      { create(:user) }
        let!(:other_team_user) { create(:user)}
        let(:team)             { object.team }
        let(:other_team)       { create(:team) }

        before do
          team_user1.add_role(:manager, team.becomes(Group))
          team_user2.add_role(:manager, team.becomes(Group))
          other_team_user.add_role(:manager, other_team.becomes(Group))
        end

        it 'creates two notification records' do
          expect {
            perform
          }.to change(Logging::Notification, :count).by(2)

          notification = Logging::Notification.first
          expect(notification.text).to eq(expected_text)
          expect(notification.url).to eq(url)
          expect(notification.priority).to eq('low')
        end

        it 'assigns the correct attribute to the notifications' do
          perform

          notification = Logging::Notification.first
          expect(notification.text).to eq(expected_text)
          expect(notification.url).to eq(url)
          expect(notification.priority).to eq('low')
        end

        it 'assigns the team users as recipients' do
          perform

          recipient_ids = Logging::Notification.pluck(:user_id)
          expect(recipient_ids).to match_array([team_user1.id, team_user2.id])
        end

        it 'enqueues a notification relay job' do
          expect {
            perform
          }.to have_enqueued_job(Logging::NotificationRelayJob)
              .exactly(:twice)
              .with(an_instance_of(Logging::Notification), an_instance_of(User))
        end
      end
    end
  end
end
