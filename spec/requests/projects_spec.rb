require 'rails_helper'

describe 'Projects API', type: :request do

  describe 'Get projects' do

    it 'should return success code' do
      get '/api/v1/projects'
      expect(response).to have_http_status(:success)
    end

    it 'should return all projects' do
      project = Project.all
      get '/api/v1/projects'
      expect(JSON.parse(response.body)).to eq(JSON.parse(project.to_json))
    end
  end

  describe 'Get specific project' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, project_name: 'project_for_test2', user_id: user.id) }

    it 'should return 404 status for invalid id' do
      get '/api/v1/projects/9999'
      expect(response).to have_http_status(:not_found)
    end

    it 'should return a specific project' do
      get "/api/v1/projects/#{project.id}"
      expect(JSON.parse(response.body)["project_name"]).to eq(project.project_name)
    end
  end

  describe 'Create a new project' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
    let!(:params) { {user_id: user.id, project_name: 'My new Project'} }

    it 'should create a new project' do
      post '/api/v1/projects', params: params
      expect(JSON.parse(response.body)["project_name"]).to eq('My new Project')
    end

    it 'should return status 201' do
      post '/api/v1/projects', params: params
      expect(response).to have_http_status(:created)
    end

    it 'should change projects count' do
      expect { post '/api/v1/projects', params: params }.to change { Project.count }.from(0).to(1)
    end
  end

  describe 'Update project' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, user_id: user.id, project_name: 'req_project_test') }
    let!(:params) { {user_id: user.id, project_name: 'name after update'} }

    it 'should update project' do
      patch "/api/v1/projects/#{project.id}", params: params
      expect(project.reload.project_name).to eq(params[:project_name])
    end

    it 'should return success status' do
      patch "/api/v1/projects/#{project.id}", params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Delete project' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, user_id: user.id, project_name: 'req_project_test') }

    it 'should return 204 status' do
      delete "/api/v1/projects/#{project.id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
