require 'rails_helper'

describe 'Tasks API', type: :request do
  describe 'Get Tasks' do
    it 'returns success code' do
      get '/api/v1/tasks'
      expect(response).to have_http_status(:success)
    end

    it 'returns all tasks' do
      tasks = Task.all
      get '/api/v1/tasks'
      expect(JSON.parse(response.body)).to eq(JSON.parse(tasks.to_json))
    end
  end

  describe 'Get specific Task' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id)
    end

    let!(:task) do
      FactoryBot.create(:task, task_name: 'Testname', status: 0, project_id: project.id, user_id: user.id,
                               performer_id: rand(1..3))
    end

    it 'returns 404 status for invalid id' do
      get '/api/v1/tasks/9999'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns specific task' do
      get "/api/v1/tasks/#{task.id}"
      expect(JSON.parse(response.body)['task_name']).to eq(task.task_name)
    end
  end

  describe 'Create new task' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id)
    end

    let!(:params) do
      { project_id: project.id, user_id: user.id, task_name: 'Task001', description: 'Тестовая задача для теста',
        status: 0, performer_id: rand(1..3), due_date: '2020-02-23' }
    end

    it 'creates a new task' do
      post '/api/v1/tasks', params: params
      expect(JSON.parse(response.body)['description']).to eq('Тестовая задача для теста')
    end

    it 'returns 201 status' do
      post '/api/v1/tasks', params: params
      expect(response).to have_http_status(:created)
    end

    it 'changes task count' do
      expect { post '/api/v1/tasks', params: params }.to change(Task, :count).from(0).to(1)
    end
  end

  describe 'Update task' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id)
    end

    let!(:task) do
      FactoryBot.create(:task, task_name: 'Тask001', status: 0, project_id: project.id, user_id: user.id,
                               performer_id: rand(1..3))
    end

    let!(:params) do
      { task_name: 'Тask001', description: 'Тестовая задача для теста', status: 2, performer_id: rand(1..3),
        due_date: '2020-02-23', deleted_at: '' }
    end

    let!(:params_for_check_status) do
      { task_name: 'Тask001', description: 'Тестовая задача для теста', status: 'resolved', performer_id: rand(1..3),
        due_date: '2020-02-23', deleted_at: '' }
    end

    it 'updates task' do
      patch "/api/v1/tasks/#{task.id}", params: params
      expect(task.reload.status).to eq(params_for_check_status[:status])
    end

    it 'returns success status' do
      patch "/api/v1/tasks/#{task.id}", params: params
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Delete task' do
    let!(:user) do
      FactoryBot.create(:user, first_name: 'user_for_test', email: 'test@jetrockets.com', password_digest: 123)
    end

    let!(:project) do
      FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id)
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

    it 'returns 204 status' do
      delete "/api/v1/tasks/#{task.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'returns value of parameter "deleted_at" = Time.now' do
      patch "/api/v1/tasks/#{task.id}", params: params_for_task_update
      delete "/api/v1/tasks/#{task.id}"
      expect(task.reload.deleted_at.strftime('%Y-%m-%d %H:%M')).to eq(params_for_check_task_result[:deleted_at])
    end
  end
end
