class User < ApplicationRecord
  has_many :user_recipes
  has_many :recipes, through: :user_recipes
  has_many :drinks, dependent: :destroy
  has_many :owned_recipes,
         through: :drinks,
         source: :recipes
         
  has_secure_password

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.search(params)
    if params[:username].present?
      by_username(params[:username])
    else
      all
    end
  end

  def self.by_username(username)
    where("username ILIKE ?", "%#{username}%")
  end
end
