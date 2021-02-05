module TaskManager
  module V1
    class Users < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      helpers V1::Helpers::UserHelpers, V1::Helpers::PresenterHelpers

      rescue_from ActiveRecord::RecordNotFound do |e|
        error!(e.message, 404)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        error!(e.message, 422)
      end

      resource :users do

        desc 'Return list of users'
        get do
          if params[:include] == 'projects'
            users = user_presenter(all_users.includes(:projects), view: :without_user_tasks)
            present users
            status :ok
          elsif params[:include] == 'projects_and_tasks' || params[:include] == 'tasks_and_projects'
            users = user_presenter(all_users.includes(:projects, :tasks), view: :with_user_projects_and_tasks)
            present users
            status :ok
          else
            users = user_presenter(all_users, view: :normal)
            present users
            status :ok
          end
        end

        desc 'Return specific user with project and his tasks'
        route_param :id do
          get do
              case
              when params[:include] == 'projects_and_tasks' || params[:include] == 'tasks_and_projects'
                user = user_presenter(current_user, view: :with_user_projects_and_tasks)
                present user
                status :ok
              when params[:include] == 'projects'
                user = user_presenter(current_user, view: :without_user_tasks)
                present user
                status :ok
              when params[:include] == 'tasks'
                user = user_presenter(current_user, view: :without_user_projects)
                present user
                status :ok
              else
                user = user_presenter(current_user, view: :normal)
                present user
                status :ok
              end
          end
        end

        desc 'Create user'
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false # пароль будет зашифрован хэш-функцией bcrypt
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
              User.mark_for_deletion(user)
              status :no_content
          end
        end
      end
    end
  end
end
