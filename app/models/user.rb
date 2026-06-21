class User < ApplicationRecord
  has_many :user_recipes
  has_many :recipes, through: :user_recipes
  has_secure_password
  
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end