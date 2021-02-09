module TaskManager
  module V1
    module Helpers
      module UserHelpers
        def all_users
          User.all
        end

        def current_user
          User.unscoped.find(params[:id])
        end
      end
    end
  end
end
