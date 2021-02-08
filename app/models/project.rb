class Project < ApplicationRecord
  has_many :tasks, dependent: :nullify
  belongs_to :user
  validates :project_name, presence: true, uniqueness: true
  default_scope { where('deleted_at is null') }

  def mark_for_deletion(current_project)
    Project.transaction do
      current_project.update!(deleted_at: Time.current)
      current_project.tasks.update_all(deleted_at: Time.current)
    end
  end
end
