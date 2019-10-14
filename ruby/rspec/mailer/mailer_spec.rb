require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  describe '#report' do
    subject(:mailer_action) { described_class.report(report, destination_emails).deliver_now }

    let(:destination_emails) { ['some_email@test.com', 'second_email@test.com'] }
    let(:company) { create(:company) }
    let!(:report) { create(:report, company: company) }

    before { Timecop.freeze(Time.local(2019, 9, 13)) }

    it 'assigns the correct subject' do
      expect(mailer_action.subject).to eq("#{company.name} September Update")
    end

    it 'sends it to the given emails' do
      expect(mailer_action.to).to eq(destination_emails)
    end

    it 'includes the report intro in the body' do
      expect(mailer_action.body.encoded).to include(report.intro)
    end
  end
end
