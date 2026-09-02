class User < ApplicationRecord
  enum :role, {
    user: "user",
    admin: "admin"
  }

  has_many :user_recipes,
           dependent: :destroy

  has_many :recipes,
           through: :user_recipes

  has_many :drinks,
           dependent: :destroy

  has_many :ingredients,
           dependent: :destroy

  has_many :owned_recipes,
           through: :drinks,
           source: :recipes

  has_secure_password

  before_validation :normalize_email

  validates :name,
            presence: true

  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :email,
            presence: true,
            uniqueness: {
              case_sensitive: false
            },
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  def self.search(params)
    return all unless params[:search].present?

    by_username(params[:search])
  end

  def self.by_username(username)
    where(
      "username ILIKE ?",
      "%#{username}%"
    )
  end

  def self.find_for_login(identifier)
    normalized_identifier =
      identifier.to_s.strip.downcase

    find_by(
      "LOWER(email) = :identifier OR LOWER(username) = :identifier",
      identifier: normalized_identifier
    )
  end

  private

  def normalize_email
    self.email =
      email.to_s.strip.downcase
  end
end
