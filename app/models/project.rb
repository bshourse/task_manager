class Project < ApplicationRecord
  has_many :tasks, dependent: :delete_all
  belongs_to :user
  validates :project_name, presence: true, uniqueness: true
end
