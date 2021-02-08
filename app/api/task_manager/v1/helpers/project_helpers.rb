module TaskManager
  module V1
    module Helpers
      module ProjectHelpers
        def all_projects
          Project.all
        end

        def current_project
          Project.unscoped.find(params[:id])
        end
      end
    end
  end
end
