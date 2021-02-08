class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :nullify
  has_many :projects, dependent: :nullify
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  default_scope { where('deleted_at is null') }

  def mark_for_deletion
    update!(deleted_at: Time.current)
  end
end
