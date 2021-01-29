class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user
  validates :task_name,
            presence: true,
            uniqueness: true,
            length: { minimum: 4, maximum: 40 }
  validates :performer_id, numericality: { only_integer: true, greater_than: 0 }
end
