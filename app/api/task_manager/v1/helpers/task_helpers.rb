module TaskManager
  module V1
    module Helpers
      module TaskHelpers

        def current_task
          Task.unscoped.find(params[:id])
        end

      end
    end
  end
end
