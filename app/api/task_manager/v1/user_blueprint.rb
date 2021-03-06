module TaskManager
  module V1
    class UserBlueprint < Blueprinter::Base
      identifier :id

      view :normal do
        fields :first_name, :last_name, :email
      end

      view :without_user_tasks do
        fields :first_name, :last_name, :email
        association :projects, blueprint: ProjectBlueprint, view: :normal_without_tasks
      end

      view :without_user_projects do
        fields :first_name, :last_name, :email
        association :tasks, blueprint: TaskBlueprint, view: :extended
      end

      view :with_user_projects_and_tasks do
        fields :first_name, :last_name, :email
        field :deleted_at, datetime_format: '%d-%B-%Y %H:%M:%S'
        association :projects, blueprint: ProjectBlueprint, view: :normal_without_tasks
        association :tasks, blueprint: TaskBlueprint, view: :normal
      end
    end
  end
end
