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
    let!(:params) { {user_id: user.id, project_name: 'name after update', deleted_at: ''} }

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
    let!(:task) { FactoryBot.create(:task, task_name: 'Тask001', status: 0, project_id: project.id, user_id: user.id, performer_id: rand(1..3)) }
    let!(:params_for_task_update) { {task_name: "Тask001", description: "Тестовая задача для теста", status: 2, performer_id: rand(1..3), due_date: "2020-02-23", deleted_at: ''} }
    let!(:params_for_check_task_result) { {task_name: "Тask001", description: "Тестовая задача для теста", status: 2, performer_id: rand(1..3), due_date: "2020-02-23", deleted_at: Time.now.utc.strftime('%Y-%m-%d %H:%M')} }
    let!(:params_for_project_update) { {user_id: user.id, project_name: 'req_project_test', deleted_at: ''} }
    let!(:params_for_check_project_result) { {user_id: user.id, project_name: 'req_project_test', deleted_at: Time.now.utc.strftime('%Y-%m-%d %H:%M')} }

    it 'should return 204 status' do
      delete "/api/v1/projects/#{project.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'should return project and related task values of parameter "deleted_at" = Time.now' do
      #Тут я проверяю что при удалении проекта обновляется поле deleted_at на текущее время
      # Следом проверяю что у связанной с проектом задачи также проставляется значение поля deleted_at
      # Обновление проекта и задачи нужно для того чтобы появилось пустое значение (не null) в бд, так как при создании объекта значение данного поля не проставляется
      patch "/api/v1/projects/#{project.id}", params: params_for_project_update
      patch "/api/v1/tasks/#{task.id}", params: params_for_task_update
      delete "/api/v1/projects/#{project.id}"
      expect(project.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_project_result[:deleted_at])
      expect(task.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_task_result[:deleted_at])
    end
  end
end
