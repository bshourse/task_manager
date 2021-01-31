module TaskManager
  module V1
    class UserBlueprint < Blueprinter::Base
      identifier :id

      view :normal do
        fields :first_name, :last_name, :email
      end

      view :without_user_tasks do # пользователи и их проекты, которые они создали
        fields :first_name, :last_name, :email
        association :projects, blueprint: ProjectBlueprint, view: :normal_without_tasks
      end

      view :with_user_projects_and_tasks do # пользователи и проекты с задачами которые они создали
        fields :first_name, :last_name, :email
        association :projects, blueprint: ProjectBlueprint, view: :normal_without_tasks
        association :tasks, blueprint: TaskBlueprint, view: :normal
      end
    end
  end
end
