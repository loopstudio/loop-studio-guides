require 'rails_helper'

RSpec.describe Reporting::IUE::ReportMailer, type: :mailer do
  describe 'report' do
    subject(:mailer_action) { described_class.report(report, destination_emails).deliver_now }

    let(:destination_emails) { ['some_email@test.com', 'second_email@test.com'] }
    let!(:report) { create(:reporting_iue_report, company: company) }
    let!(:company) { create(:business_company_datum) }
    let!(:entries) do
      create_list(:reporting_iue_report_section, 2, report: report)
    end

    before { Timecop.freeze(Time.local(2019, 9, 13)) }

    it 'assigns the correct subject' do
      expect(mailer_action.subject).to eq("#{company.name} September Update")
    end

    it 'sends it to the given emails' do
      expect(mailer_action.to).to eq(destination_emails)
    end

    it 'includes the entries texts in the body' do
      body = mailer_action.body.encoded

      report.entries.each do |entry|
        expect(body).to match(entry.text)
        expect(body).to match(entry.section.name)
      end
    end
  end
end