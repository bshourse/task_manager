class Project < ApplicationRecord
  has_many :tasks
  belongs_to :user
  validates :project_name, presence: true
end
