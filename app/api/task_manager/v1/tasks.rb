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
        end

        desc 'Return a specific task'
        route_param :id do
          begin
            get do
              task = TaskBlueprint.render_as_json(Task.find(params[:id]), view: :extended)
              present task
              status :ok
            rescue ActiveRecord::RecordNotFound => e
              error!(e, :not_found)
            end
          end
        end
      end
    end
  end
end
