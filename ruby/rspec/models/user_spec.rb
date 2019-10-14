require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  describe 'relations' do
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:name).is_at_least(2) }

    context 'when the user does not have a group' do
      subject(:user) { build(:user) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end

    describe 'email validation' do
      let(:email) { 'test@email.com' }

      context 'when the email exists but for a different group' do
        subject(:valid_user) { build(:user, email: email) }
        let!(:other_group_user_with_same_email) { create(:user, email: email) }

        it { is_expected.to be_valid }
      end

      context 'when the user email exists in the same group' do
        subject(:invalid_user) do
          build(:user, group: group, email: email)
        end

        let!(:same_group_user_with_same_email) do
          create(:user, email: email, group: invalid_user.group)
        end

        it { is_expected.to_not be_valid }
      end
    end
  end
end
