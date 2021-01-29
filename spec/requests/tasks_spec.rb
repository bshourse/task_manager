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

    let!(:user) { FactoryBot.create(:user, first_name: 'user_for_test', password_digest: 123) }
    let!(:project) { FactoryBot.create(:project, project_name: 'project_for_test', user_id: user.id) }
    let!(:task) { FactoryBot.create(:task, task_name: 'Testname', project_id: project.id, user_id: user.id) }

    it 'should return 404 status for invalid id' do
      get '/api/v1/tasks/9999'
      expect(response).to have_http_status(:not_found)
    end

    it 'should return specific task' do
      get "/api/v1/tasks/#{task.id}"
      expect(JSON.parse(response.body)["task_name"]).to eq(task.task_name)
    end

  end
end
