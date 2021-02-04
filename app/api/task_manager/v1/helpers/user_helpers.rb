module TaskManager
  module V1
    module Helpers
      module UserHelpers

        def all_users
          User.all
        end

        def current_user
          User.find(params[:id])
        end

      end
    end
  end
end
