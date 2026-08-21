class Api::V1::AccountController < ApplicationController
  def destroy
    unless params[:confirmation] == "DELETE"
      render json: {
        errors: [ "Type DELETE to confirm account deletion" ]
      }, status: :unprocessable_content

      return
    end

    current_user.destroy!
    reset_session

    head :no_content
  end
end