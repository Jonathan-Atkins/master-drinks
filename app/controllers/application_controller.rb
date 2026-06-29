class ApplicationController < ActionController::API
  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    render json: { errors: [ "You must be logged in" ] }, status: :unauthorized
  end
  private

  def record_not_found(error)
    render json: { errors: [ error.message ] }, status: :not_found
  end
end
