class UsersController < ApplicationController
  before_action :authenticate_user!
  def show
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:success] = "Your profile has been updated."
      redirect_to profile_user_path
    else
      render 'show'
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :locale)
  end
end
