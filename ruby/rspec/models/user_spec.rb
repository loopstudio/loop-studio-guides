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

    context 'when the user does not have a group' do
      subject(:user) { build(:user) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end

    context 'when the user has a group' do
      let(:name) { 'Test' }

      context 'when the name exists but for a different group' do
        
        subject(:valid_user) { build(:user, :with_group, name: name) }
        let!(:user) { create(:user, :with_group, name: name) }

        it { is_expected.to be_valid }
      end

      context 'when the name exists for the same group' do
        subject(:invalid_user) do
          build(:user, group: user.group, name: name)
        end

        let!(:user) { create(:user, :with_group, name: name) }

        it { is_expected.to_not be_valid }
      end

      context 'when there is a default user with the same name' do
        subject(:invalid_user) { build(:user, :with_group, name: name) }
        let!(:user) { create(:user, name: name) }

        it { is_expected.to_not be_valid }
      end
    end
  end
end
