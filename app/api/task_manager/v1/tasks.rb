module TaskManager
  module V1
    class Tasks < Grape::API
      version 'v1', using: :path # тут указываю версию апи
      format :json # тут говорим нашему апи что ожидаем и используем только json
      prefix :api # с этим префиксом я получаю доступ к точкам входа /api в роутах же задал TaskManager::Base => '/'

      helpers V1::Helpers::TaskHelpers, V1::Helpers::PresenterHelpers

      rescue_from ActiveRecord::RecordNotFound do |e|
        error!(e.message, 404)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(e.message, 422)
      end

      resource :tasks do

        desc 'Return list of tasks'
        get do
          tasks = task_presenter(Task.all.where("deleted_at is null"), view: :normal)
          present tasks
          status :ok
        end

        desc 'Return a specific task'
        route_param :id do
          get do
              task = task_presenter(current_task, view: :extended)
              present task
              status :ok
          end
        end

        desc 'Create task'
        params do
          requires :project_id, type: Integer
          requires :user_id, type: Integer
          requires :task_name, type: String, allow_blank: false
          requires :description, type: String
          requires :status, type: String, except_values: { value: ['In Progress','Closed','Resolved','Reopen'], message: 'when you create a task should be only - Open' }
          optional :performer_id, type: Integer
          optional :due_date, type: Date
        end

        post do
            task = task_presenter(Task.create!(declared(params)), view: :extended)
            present task
            status :created
        end

        desc 'Update task'
        params do
          requires :task_name, type: String, allow_blank: false
          requires :description, type: String
          requires :status, type: String, values: { value: ['Open', 'In Progress', 'Reopen', 'Resolved', 'Closed'], message: 'when you update a task should be Open/In Progress/Resolved/Reopen or Closed'}
          requires :performer_id, type: Integer
          requires :due_date, type: Date
          requires :deleted_at, type: DateTime
        end
        route_param :id do
          patch do
              task = current_task
              task.update!(declared(params))
              updated_task = task_presenter(task, view: :extended)
              present updated_task
              status :ok
          end
        end

        desc 'Delete task'
        route_param :id do
          delete do
              task = current_task
              task.update!(deleted_at: Time.now)
              status :no_content
          end
        end
      end
    end
  end
end
