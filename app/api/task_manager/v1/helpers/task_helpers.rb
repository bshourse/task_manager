module TaskManager
  module V1
    module Helpers
      module TaskHelpers

        def current_task
          Task.find(params[:id])
        end

      end
    end
  end
end
