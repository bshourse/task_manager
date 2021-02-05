class Project < ApplicationRecord
  has_many :tasks
  belongs_to :user
  validates :project_name, presence: true, uniqueness: true
  default_scope { where("deleted_at is null") }

  def self.mark_for_deletion(project)
    project.update!(deleted_at: Time.now)
    if Task.exists?(:project_id => "#{project.id}") # тут делаю проверку чтобы лишний раз не пытать обновить задачи, если у проекта их нет
      task = Task.where("project_id = #{project.id}")
      task.update_all(deleted_at: Time.now)
    end
  end

end
