class Api::V1::ProfilesController < ApplicationController
  def show
    user = User.find_by!(
      username: params[:username]
    )

    render json: UserProfileSerializer.format(user),
           status: :ok
  end
end
