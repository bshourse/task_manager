module TaskManager
  module V1
    class Projects < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :projects do

        desc 'Return list of projects'
        get do
          projects = ProjectBlueprint.render_as_json(Project.all.includes(:tasks).where("deleted_at is null"), view: :normal_with_tasks) # вызываю includes для исключения проблемы n+1
          present projects
          status :ok
        end

        desc 'Return a specific project'
        route_param :id do
          get do
            begin
              project = ProjectBlueprint.render_as_json(Project.find(params[:id]), view: :normal_with_tasks)
              present project
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
            end
          end
        end

        desc 'Create project'
        params do
          requires :user_id, type: Integer
          requires :project_name, type: String, allow_blank: false
        end

        post do
          begin
            project = ProjectBlueprint.render_as_json(Project.create!(declared(params)), view: :normal_without_tasks)
            present project
            status :created
          rescue ActiveRecord::RecordInvalid => e
            error!(e, :unprocessable_entity)
          end
        end

        desc 'Update project'
        params do
          requires :project_name, type: String, allow_blank: false
          requires :deleted_at, type: DateTime
        end

        route_param :id do
          patch do
            begin
              project = Project.find(params[:id])
              project.update!(declared(params))
              updated_project = ProjectBlueprint.render_as_json(project, view: :normal_without_tasks)
              present updated_project
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)

            rescue ActiveRecord::RecordInvalid => e
              error!(e, :unprocessable_entity)
            end
          end
        end

        desc 'Delete project'
        route_param :id do
          delete do
            begin
              project = Project.find(params[:id])
              project.update!(deleted_at: Time.now)
              if Task.exists?(:project_id => "#{project.id}") # тут делаю проверку чтобы лишний раз не пытать обновить задачи, если у проекта их нет
                task = Task.where("project_id = #{project.id}")
                task.update_all(deleted_at: Time.now)
              end
              status :no_content
            rescue ActiveRecord::RecordNotFound => e
              error!(e, not_found)
            end
          end
        end
      end
    end
  end
end
