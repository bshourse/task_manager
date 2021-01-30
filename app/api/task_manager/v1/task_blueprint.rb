module TaskManager
  module V1
    class TaskBlueprint < Blueprinter::Base
      identifier :id

      view :normal do
        fields  :user_id, :project_id, :task_name, :status, :due_date
      end

      view :extended do
        include_view :normal
        fields :description, :implementation_time
      end
    end
  end
end

