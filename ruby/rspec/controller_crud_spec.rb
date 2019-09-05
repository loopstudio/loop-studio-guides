require 'rails_helper'

RSpec.describe 'UsersControllerRequests', type: :request do

  describe '#index' do
    subject do
      get '/api/users'
      response
    end

    let(:users) do
      [
        create(:user, id: 1, name: 'John', email: 'john@test'),
        create(:user, id: 2, name: 'Alice', email: 'alice@test'),
        create(:user, id: 3, name: 'Bob', email: 'bob@test')
      ]
    end

    before do
      allow_any_instance_of(Api::UsersController)
        .to receive(:current_api_user).and_return(create(:user))
    end

    context 'when no extra params are sent' do
      it { is_expected.to be_ok }
      
      it { is_expected.to match_response_schema('users/index') }

      it 'returns all the users' do
        expected_response = {
          data: [
            { id: 1 },
            { id: 2 },
            { id: 3 }
          ]
        }
        expect(subject.body).to include_json(expected_response)
      end
    end

    context 'when searching by name' do
      subject do
        get '/api/users', params: { name: name }
        response
      end

      let(:name) { 'Alice' }

      it { is_expected.to be_ok }

      it { is_expected.to match_response_schema('users/index') }

      it 'includes the correct users' do
        expected_response = {
          data: [
            { id: 2 },
          ]
        }
        expect(subject.body).to include_json(expected_response)
      end
    end

    context 'when user is not correctly authenticated' do
      before do
        allow_any_instance_of(Api::UsersController)
          .to receive(:current_api_user).and_return(nil)
      end

      it { is_expected.to be_unauthorized }

      it 'renders an unauthorized message' do
        expect(subject.body).to include_json(errors: ['You need to be logged it before continuing.'])
      end
    end
  end

  describe '#show' do
    subject do
      get "/api/users/#{user_id}"
      response
    end

    let(:user) { create(:user, user: user) }
    let(:user_id) { user.id }

    before do
      allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(user)
    end

    context 'when sending an id of an existing user' do
      it { is_expected.to be_ok }

      it { is_expected.to match_response_schema('users/show') }
    end

    context "when user doesn't exist" do
      let(:user_id) { -1 }

      it { is_expected.to be_not_found }

      it 'has the not found error description' do
        expect(subject.body).to include_json(errors: ['User not found.'])
      end
    end

    context 'when user is not correctly authenticated' do
      before do
        allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(nil)
      end

      it { is_expected.to be_unauthorized }

      it 'renders an unauthorized message' do
        expect(subject.body).to include_json(errors: ['You need to be logged it before continuing.'])
      end
    end
  end

  describe '#create' do
    subject do
      post '/api/users', params: user_attributes
      response
    end

    let(:user_attributes) { build(:user).attributes }

    before do
      allow_any_instance_of(Api::UsersController)
        .to receive(:current_api_user).and_return(create(:user))
    end

    context 'when creating a correct user' do
      it { is_expected.to be_ok }

      it { is_expected.to match_response_schema('users/create') }

      it 'has the correct user attributes' do
        expected_response = {
          data: {
            attributes: user_attributes.except('id', 'created_at', 'updated_at')
          }
        }
        expect(subject.body).to include_json(expected_response)
      end
    end
    
    context 'when the user is invalid' do
      let(:user_attributes) { build(:user).attributes.except('name') }

      it { is_expected.to be_unprocessable }

      it 'renders the error messages' do
        expect(subject.body).to include_json(errors: ["Name can't be blank"])
      end
    end

    context 'when user is not correctly authenticated' do
      before do
        allow_any_instance_of(Api::UsersController)
          .to receive(:current_api_user).and_return(nil)
      end

      it { is_expected.to be_unauthorized }

      it 'renders an unauthorized message' do
        expect(subject.body).to include_json(errors: ['You need to be logged it before continuing.'])
      end
    end
  end

  describe '#update' do
    subject do
      patch "/api/users/#{user.id}", params: new_attributes
      response
    end

    let(:new_attributes) do
      {
        id: user.id,
        name: 'New Name',
        email: 'newmail@test',
      }
    end

    before do
      allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(user)
    end

    context 'when updating a user correctly' do
      it { is_expected.to be_ok }

      it { is_expected.to match_response_schema('users/update') }
  
      it 'has the correct user attributes' do
        expected_response = { data: { attributes: new_attributes } }
        expect(subject.body).to include_json(expected_response)
      end
    end

    context 'when attributes are invalid' do
      before { new_attributes.merge!(email: 'invalid_mail') }

      it { is_expected.to be_unprocessable }

      it 'renders the error messages' do
        expect(subject.body).to include_json(errors: ['Email is invalid'])
      end
    end

    context 'when user to update is not the current user' do
      before do
        allow_any_instance_of(Api::UsersController)
          .to receive(:current_api_user).and_return(create(:user))
      end

      it { is_expected.to be_unauthorized }

      it "renders a don't have permission message" do
        expect(subject.body).to include_json(errors: ["You don't have permission to perform this action"])
      end
    end

    context 'when user is not correctly authenticated' do
      before do
        allow_any_instance_of(Api::UsersController)
          .to receive(:current_api_user).and_return(nil)
      end

      it { is_expected.to be_unauthorized }

      it 'renders an unauthorized message' do
        expect(subject.body).to include_json(errors: ['You need to be logged it before continuing.'])
      end
    end
  end

  describe '#destroy' do
    subject do
      delete "/api/users/#{user.id}"
      response
    end

    let(:user) { create(:user, user: user) }
    let(:user) { create(:user) }

    before do
      allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(user)
    end

    context 'when deleting a user correctly' do
      it { is_expected.to be_ok }

      it { is_expected.to match_response_schema('users/destroy') }
    end

    context 'when logged user is different from user to delete' do
      before { allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(create(:user)) }

      it { is_expected.to be_unauthorized }
      
      it "renders a don't have permission message" do
        expect(subject.body).to include_json(errors: ["You don't have permission to perform this action"])
      end
    end

    context 'when user is not correctly authenticated' do
      before do
        allow_any_instance_of(Api::UsersController).to receive(:current_api_user).and_return(nil)
      end

      it { is_expected.to be_unauthorized }

      it 'renders an unauthorized message' do
        expect(subject.body).to include_json(errors: ['You need to be logged it before continuing.'])
      end
    end
  end
end
