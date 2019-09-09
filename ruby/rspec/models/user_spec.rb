require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:section) { create(:reporting_iue_section) }

  describe 'relations' do
    specify do
      is_expected.to have_many(:report_sections).class_name('Reporting::IUE::ReportSection')
        .with_foreign_key('reporting_subject_id')
    end
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:name).is_at_least(2) }

    context 'when the section does not have a group' do
      subject(:section) { build(:reporting_iue_section) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end

    context 'when the section has a group' do
      let(:name) { 'Test' }

      context 'when the name exists but for a different group' do
        subject(:valid_section) { build(:reporting_iue_section, :with_group, name: name) }
        let!(:section) { create(:reporting_iue_section, :with_group, name: name) }

        it { is_expected.to be_valid }
      end

      context 'when the name exists for the same group' do
        subject(:invalid_section) do
          build(:reporting_iue_section, group: section.group, name: name)
        end

        let!(:section) { create(:reporting_iue_section, :with_group, name: name) }

        it { is_expected.to_not be_valid }
      end

      context 'when there is a default section with the same name' do
        subject(:invalid_section) { build(:reporting_iue_section, :with_group, name: name) }
        let!(:section) { create(:reporting_iue_section, name: name) }

        it { is_expected.to_not be_valid }
      end
    end
  end
end