module TaskManager
  module V1
    class ProjectBlueprint < Blueprinter::Base
      identifier :id

      view :normal_with_tasks do
        fields :user_id, :project_name
        field :created_at, datetime_format: "%d-%m-%Y"
        field :deleted_at, datetime_format: "%d-%B-%Y %H:%M:%S"
        association :tasks, blueprint: TaskBlueprint, view: :short
      end

      view :normal_without_tasks do
        fields :user_id, :project_name
        field :created_at, datetime_format: "%d-%m-%Y"
      end

    end
  end
end
