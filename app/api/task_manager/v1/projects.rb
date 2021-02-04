module TaskManager
  module V1
    class Projects < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      helpers V1::Helpers::ProjectHelpers, V1::Helpers::PresenterHelpers

      rescue_from ActiveRecord::RecordNotFound do |e|
        error!(e.message, 404)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(e.message, 422)
      end

      resource :projects do

        desc 'Return list of projects'
        get do
          if params[:include] == 'tasks' # если вызываем get /projects?include=tasks то ответ содержит проекты и связанные задачи
            projects = project_presenter(all_projects.includes(:tasks).where("deleted_at is null"), view: :normal_with_tasks)
            present projects
            status :ok
          else # если вызываем без дополнительного параметра get /projects то ответ содержит только проекты
            projects = project_presenter(all_projects.where("deleted_at is null"), view: :normal_without_tasks)
            present projects
            status :ok
          end
        end

        desc 'Return a specific project'
        route_param :id do
          get do
              if params[:include] == 'tasks'
                project = project_presenter(current_project, view: :normal_with_tasks)
                present project
                status :ok
              else
                project = project_presenter(current_project, view: :normal_without_tasks)
                present project
                status :ok
              end
          end
        end

        desc 'Create project'
        params do
          requires :user_id, type: Integer
          requires :project_name, type: String, allow_blank: false
        end

        post do
            project = project_presenter(Project.create!(declared(params)), view: :normal_without_tasks)
            present project
            status :created
        end

        desc 'Update project'
        params do
          requires :project_name, type: String, allow_blank: false
          requires :deleted_at, type: DateTime
        end

        route_param :id do
          patch do
              project = current_project
              project.update!(declared(params))
              updated_project = project_presenter(project, view: :normal_without_tasks)
              present updated_project
              status :ok
          end
        end

        desc 'Delete project'
        route_param :id do
          delete do
              project = current_project
              project.update!(deleted_at: Time.now)
              if Task.exists?(:project_id => "#{project.id}") # тут делаю проверку чтобы лишний раз не пытать обновить задачи, если у проекта их нет
                task = Task.where("project_id = #{project.id}")
                task.update_all(deleted_at: Time.now)
              end
              status :no_content
          end
        end
      end
    end
  end
end
