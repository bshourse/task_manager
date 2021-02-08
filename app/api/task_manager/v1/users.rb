module TaskManager
  module V1
    class Users < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      helpers V1::Helpers::UserHelpers, V1::Helpers::PresenterHelpers

      resource :users do
        desc 'Return list of users'
        get do
          case params[:include]
          when 'projects'
            users = user_presenter(all_users.includes(:projects), view: :without_user_tasks)
          when 'projects_and_tasks', 'tasks_and_projects'
            users = user_presenter(all_users.includes(:projects, :tasks), view: :with_user_projects_and_tasks)
          else
            users = user_presenter(all_users, view: :normal)
          end
          present users
          status :ok
        end

        desc 'Return specific user with project and his tasks'
        route_param :id do
          get do
            case params[:include]
            when 'projects_and_tasks', 'tasks_and_projects'
              user = user_presenter(current_user, view: :with_user_projects_and_tasks)
            when 'projects'
              user = user_presenter(current_user, view: :without_user_tasks)
            when 'tasks'
              user = user_presenter(current_user, view: :without_user_projects)
            else
              user = user_presenter(current_user, view: :normal)
            end
            present user
            status :ok
          end
        end

        desc 'Create user'
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
        end

        post do
          user = user_presenter(User.create!(declared(params)), view: :normal)
          present user
          status :created
        end

        desc 'Update user'
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          requires :deleted_at, type: DateTime
        end

        route_param :id do
          patch do
            user = current_user
            user.update!(declared(params))
            updated_user = user_presenter(user, view: :normal)
            present updated_user
            status :ok
          end
        end

        desc 'Delete user'
        route_param :id do
          delete do
            user = current_user
            user.mark_for_deletion
            status :no_content
          end
        end
      end
    end
  end
end
