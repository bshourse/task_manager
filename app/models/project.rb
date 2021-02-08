class Project < ApplicationRecord
  has_many :tasks
  belongs_to :user
  validates :project_name, presence: true, uniqueness: true
  default_scope { where("deleted_at is null") }

  def mark_for_deletion(current_project)
    Project.transaction do
      current_project.update!(deleted_at: Time.now)
      current_project.tasks.update_all(deleted_at: Time.now)
    end
  end

end
