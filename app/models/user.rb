class User < ApplicationRecord
  has_many :user_drinks
  has_many :drinks, through: :user_drinks
  
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end