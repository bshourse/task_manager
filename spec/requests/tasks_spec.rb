require 'rails_helper'

describe 'Tasks API', type: :request do

  describe 'Get Tasks' do

    it 'should return success code' do
      get '/api/v1/tasks'
      expect(response).to have_http_status(:success)
    end

    it 'should return all tasks' do
      tasks = Task.all
      get '/api/v1/tasks'
      expect(JSON.parse(response.body)).to eq(JSON.parse(tasks.to_json))
    end
  end

  describe 'Get specific Task' do

    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: "test@jetrockets.com", password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id) }
    let!(:task) { FactoryBot.create(:task, task_name: 'Testname', status: "Open", project_id: project.id, user_id: user.id, performer_id: rand(1..3)) }

    it 'should return 404 status for invalid id' do
      get '/api/v1/tasks/9999'
      expect(response).to have_http_status(:not_found)
    end

    it 'should return specific task' do
      get "/api/v1/tasks/#{task.id}"
      expect(JSON.parse(response.body)["task_name"]).to eq(task.task_name)
    end

  end

  describe 'Create new task' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: "test@jetrockets.com", password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id) }
    let!(:params) { {project_id: project.id, user_id: user.id, task_name: "Task001", description: "Тестовая задача для теста", status: "Open", performer_id: rand(1..3), due_date: "2020-02-23"} }

    it 'should create a new task' do
      post '/api/v1/tasks', params: params
      expect(JSON.parse(response.body)["description"]).to eq('Тестовая задача для теста')
    end

    it 'should return 201 status' do
      post '/api/v1/tasks', params: params
      expect(response).to have_http_status(:created)
    end

    it 'should change task count' do
      expect { post '/api/v1/tasks', params: params }.to change { Task.count }.from(0).to(1)
    end
  end

  describe 'Update task' do
    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', email: "test@jetrockets.com", password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id) }
    let!(:task) { FactoryBot.create(:task, task_name: 'Тask001', status: "Open", project_id: project.id, user_id: user.id, performer_id: rand(1..3)) }
    let!(:params) { {task_name: "Тask001", description: "Тестовая задача для теста", status: "Resolved", performer_id: rand(1..3), due_date: "2020-02-23"} }

    it 'should update task' do
      patch "/api/v1/tasks/#{task.id}", params: params
      expect(task.reload.status).to eq(params[:status])
    end

    it 'should return success status' do
      patch "/api/v1/tasks/#{task.id}", params: params
      expect(response).to have_http_status(:success)
    end
  end
end
