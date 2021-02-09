module TaskManager
  module V1
    module Helpers
      module PresenterHelpers
        def project_presenter(project_collection, view)
          ProjectBlueprint.render_as_json(project_collection, view)
        end

        def task_presenter(task_collection, view)
          TaskBlueprint.render_as_json(task_collection, view)
        end

        def user_presenter(user_collection, view)
          UserBlueprint.render_as_json(user_collection, view)
        end
      end
    end
  end
end
