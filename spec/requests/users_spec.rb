require 'rails_helper'

describe 'Users API', type: :request do

  describe 'Get all users' do

    it 'should return success code' do
      get '/api/v1/users'
      expect(response).to have_http_status(:success)
    end

    it 'should return all users' do
      user = User.all
      get '/api/v1/users'
      expect(JSON.parse(response.body)).to eq(JSON.parse(user.to_json))
    end

    describe 'Get specific user' do
      let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }

      it 'should return 404 status for invalid id' do
        get '/api/v1/users/9999'
        expect(response).to have_http_status(:not_found)
      end

      it 'should return a specific user' do
        get "/api/v1/users/#{user.id}"
        expect(JSON.parse(response.body)["email"]).to eq(user.email)
      end
    end

    describe 'Create new user' do
      let!(:params) { {first_name: 'Test', last_name: 'Test_last_name', email: 'test2@jetrockets.com', password: 123} }

      it 'should create a new user' do
        post '/api/v1/users', params: params
        expect(JSON.parse(response.body)['first_name']).to eq('Test')
      end

      it 'should return status 201' do
        post '/api/v1/users', params: params
        expect(response).to have_http_status(:created)
      end

      it 'should change users count' do
        expect { post '/api/v1/users', params: params }.to change { User.count }.from(0).to(1)
      end
    end

    describe 'Update user' do
      let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
      let!(:params) { {first_name: 'user_first_name', last_name: 'new_last_name', email: 'test2@jetrockets.com', password: 123, deleted_at: ''} }

      it 'should update user' do
        patch "/api/v1/users/#{user.id}", params: params
        expect(user.reload.last_name).to eq(params[:last_name])
      end

      it 'should return success status' do
        patch "/api/v1/users/#{user.id}", params: params
        expect(response).to have_http_status(:success)
      end
    end

    describe 'Delete user' do
      let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
      let!(:params_for_user_update) { {first_name: 'user_first_name', last_name: 'new_last_name', email: 'test2@jetrockets.com', password: 123, deleted_at: ''} }
      let!(:params_for_check_user_result) { {first_name: 'user_first_name', last_name: 'new_last_name', email: 'test2@jetrockets.com', password: 123, deleted_at: Time.now.utc.strftime('%Y-%m-%d %H:%M')} }

      it 'should return 204 status' do
        delete "/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:no_content)
      end

      it 'should return value of parameter "deleted_at" = Time.now' do
        patch "/api/v1/users/#{user.id}", params: params_for_user_update
        delete "/api/v1/users/#{user.id}"
        expect(user.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_user_result[:deleted_at])
      end

    end
  end
end
