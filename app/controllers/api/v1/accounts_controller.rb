class Api::V1::AccountsController < ApplicationController
  def destroy
    unless params[:confirmation] == "DELETE"
      render json: {
        errors: [
          "Confirmation must be DELETE"
        ]
      },
             status: :unprocessable_content

      return
    end

    user = current_user

    session.delete(:user_id)

    user.destroy

    head :no_content
  end
end