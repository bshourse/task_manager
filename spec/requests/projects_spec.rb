require 'rails_helper'

describe 'Projects API', type: :request do
  describe 'Get projects' do
    it 'returns success code' do
      get '/api/v1/projects'
      expect(response).to have_http_status(:success)
    end

    it 'returns all projects' do
      project = Project.all
      get '/api/v1/projects'
      expect(JSON.parse(response.body)).to eq(JSON.parse(project.to_json))
    end
  end

  describe 'Get specific project' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, project_name: 'project_for_test2', user_id: user.id)
    end

    it 'returns 404 status for invalid id' do
      get '/api/v1/projects/9999'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a specific project' do
      get "/api/v1/projects/#{project.id}"
      expect(JSON.parse(response.body)['project_name']).to eq(project.project_name)
    end
  end

  describe 'Create a new project' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123)
    end

    let!(:params) do
      { user_id: user.id, project_name: 'My new Project' }
    end

    it 'creates a new project' do
      post '/api/v1/projects', params: params
      expect(JSON.parse(response.body)['project_name']).to eq('My new Project')
    end

    it 'returns status 201' do
      post '/api/v1/projects', params: params
      expect(response).to have_http_status(:created)
    end

    it 'changes projects count' do
      expect { post '/api/v1/projects', params: params }.to change(Project, :count).from(0).to(1)
    end
  end

  describe 'Update project' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, user_id: user.id, project_name: 'req_project_test')
    end

    let!(:params) do
      { user_id: user.id, project_name: 'name after update', deleted_at: '' }
    end

    it 'updates project' do
      patch "/api/v1/projects/#{project.id}", params: params
      expect(project.reload.project_name).to eq(params[:project_name])
    end

    it 'returns success status' do
      patch "/api/v1/projects/#{project.id}", params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Delete project' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test2@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, user_id: user.id, project_name: 'req_project_test')
    end

    let!(:task) do
      FactoryBot.create(:task, task_name: 'Тask001', status: 0, project_id: project.id, user_id: user.id,
                               performer_id: rand(1..3))
    end

    let!(:params_for_task_update) do
      { task_name: 'Тask001', description: 'Тестовая задача для теста', status: 2, performer_id: rand(1..3),
        due_date: '2020-02-23', deleted_at: '' }
    end

    let!(:params_for_check_task_result) do
      { task_name: 'Тask001', description: 'Тестовая задача для теста', status: 2, performer_id: rand(1..3),
        due_date: '2020-02-23', deleted_at: Time.now.utc.strftime('%Y-%m-%d %H:%M') }
    end

    let!(:params_for_project_update) do
      { user_id: user.id, project_name: 'req_project_test', deleted_at: '' }
    end

    let!(:params_for_check_project_result) do
      { user_id: user.id, project_name: 'req_project_test', deleted_at: Time.now.utc.strftime('%Y-%m-%d %H:%M') }
    end

    it 'returns 204 status' do
      delete "/api/v1/projects/#{project.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'returns project and related task values of parameter "deleted_at" = Time.now' do
      # Here i check that when the project is deleted, the deleted_at field is updated to the current time
      # Next, i check that the task associated with the project also has the value of the deleted_at
      patch "/api/v1/projects/#{project.id}", params: params_for_project_update
      patch "/api/v1/tasks/#{task.id}", params: params_for_task_update
      delete "/api/v1/projects/#{project.id}"
      expect(project.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_project_result[:deleted_at])
      expect(task.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_task_result[:deleted_at])
    end
  end
end
