module TaskManager
  module V1
    class Tasks < Grape::API
      version 'v1', using: :path # тут указываю версию апи
      format :json # тут говорим нашему апи что ожидаем и используем только json
      prefix :api # с этим префиксом я получаю доступ к точкам входа /api в роутах же задал TaskManager::Base => '/'

      helpers V1::Helpers::TaskHelpers, V1::Helpers::PresenterHelpers

      resource :tasks do

        desc 'Return list of tasks'
        get do
          tasks = task_presenter(Task.all, view: :normal)
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
          requires :status, type: Integer, except_values: { value: [1, 2, 3, 4], message: 'when you create a task should be only: 0 - Open' }
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
          requires :status, type: Integer, values: { value: [0, 1, 2, 3, 4], message: 'when you update a task should be 0 - Open | 1 - in_progress | 2 - resolved | 3 - reopen | 4 - closed'}
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
            task.mark_for_deletion
            status :no_content
          end
        end
      end
    end
  end
end
