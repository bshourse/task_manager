module TaskManager
  module V1
    class Projects < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      helpers V1::Helpers::ProjectHelpers, V1::Helpers::PresenterHelpers

      resource :projects do
        desc 'Return list of projects'
        get do
          projects = if params[:include] == 'tasks' # if i call get /projects?include=tasks response contains projects and related tasks
                       project_presenter(all_projects.includes(:tasks), view: :normal_with_tasks)
                     else # if i call get /projects response contains only projects
                       project_presenter(all_projects, view: :normal_without_tasks)
                     end
          present projects
          status :ok
        end

        desc 'Return a specific project'
        route_param :id do
          get do
            project = if params[:include] == 'tasks'
                        project_presenter(current_project, view: :normal_with_tasks)
                      else
                        project_presenter(current_project, view: :normal_without_tasks)
                      end
            present project
            status :ok
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
            project.mark_for_deletion(project)
            status :no_content
          end
        end
      end
    end
  end
end
