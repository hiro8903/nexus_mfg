class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :user_code, presence: true, uniqueness: true
  validates :name, presence: true
end
