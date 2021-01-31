module TaskManager
  module V1
    class Users < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :users do

        desc 'Return list of users'
        get do
          users = UserBlueprint.render_as_json(User.all.includes(:projects), view: :without_user_tasks)
          present users
          status :ok
        end

        desc 'Return specific user with project and his tasks'
        route_param :id do
          get do
            begin
              user = UserBlueprint.render_as_json(User.find(params[:id]), view: :with_user_projects_and_tasks)
              present user
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
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
          begin
            user = UserBlueprint.render_as_json(User.create!(declared(params)), view: :normal)
            present user
            status :created
          rescue ActiveRecord::RecordInvalid => e
            error!(e, :unprocessable_entity)
          end
        end

        desc 'Update user'
        params do
          requires :first_name, type: String, allow_blank: false
          requires :last_name, type: String, allow_blank: false
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
        end

        route_param :id do
          patch do
            begin
              user = User.find(params[:id])
              user.update!(declared(params))
              updated_user = UserBlueprint.render_as_json(user, view: :normal)
              present updated_user
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
            rescue ActiveRecord::RecordInvalid => e
              error!(e, :unprocessable_entity)
            end
          end
        end

        desc 'Delete user'
        route_param :id do
          delete do
            begin
              User.find(params[:id]).delete
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
