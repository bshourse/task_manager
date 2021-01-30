module TaskManager
  module V1
    class Tasks < Grape::API
      version 'v1', using: :path # тут указываю версию апи
      format :json # тут говорим нашему апи что ожидаем и используем только json
      prefix :api # с этим префиксом я получаю доступ к точкам входа /api в роутах же задал TaskManager::Base => '/'

      resource :tasks do

        desc 'Return list of tasks'
        get do
          tasks = TaskBlueprint.render_as_json(Task.all, view: :normal)
          present tasks
          status :ok
        end

        desc 'Return a specific task'
        route_param :id do
          get do
            begin
              task = TaskBlueprint.render_as_json(Task.find(params[:id]), view: :extended)
              present task
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
            end
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
          begin
            task = TaskBlueprint.render_as_json(Task.create!(declared(params)), view: :extended)
            present task #разобраться с кастомным соообшением
            status :created
          rescue ActiveRecord::RecordInvalid => e
            error!(e, :unprocessable_entity)
          end
        end

        desc 'Update task'
        params do
          requires :task_name, type: String, allow_blank: false
          requires :description, type: String
          requires :status, type: String, values: { value: ['Open', 'In Progress', 'Reopen', 'Resolved', 'Closed'], message: 'when you update a task should be Open/In Progress/Resolved/Reopen or Closed'}
          requires :performer_id, type: Integer
          requires :due_date, type: Date
        end
        route_param :id do
          patch do
            begin
              task = Task.find(params[:id])
              task.update!(declared(params)) # Работает но хорошо бы подумать как переписать, отдает TrueClass
              updated_task = TaskBlueprint.render_as_json(task, view: :extended)
              present updated_task
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)

            rescue ActiveRecord::RecordInvalid => e
              error!(e, :unprocessable_entity)
            end
          end
        end

        desc 'Delete task'
        route_param :id do
          delete do
            begin
              Task.find(params[:id]).delete
              status :no_content
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
            end
          end
        end
      end
    end
  end
end
