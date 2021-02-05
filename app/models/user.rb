class User < ApplicationRecord
  has_secure_password
  has_many :tasks
  has_many :projects
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  default_scope { where("deleted_at is null") }

  def self.mark_for_deletion(user)
    user.update!(deleted_at: Time.now)
  end

end
