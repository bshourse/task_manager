class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user
  validates :task_name,
            presence: true,
            uniqueness: true,
            length: { minimum: 4, maximum: 40 }
  validates :performer_id, numericality: { only_integer: true, greater_than: 0 }
  enum status: { open: 0, in_progress: 1, resolved: 2, reopen: 3, closed: 4 }
  default_scope { where("deleted_at is null") }
end
