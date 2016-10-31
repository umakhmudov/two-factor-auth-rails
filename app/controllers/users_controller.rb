class UsersController < ApplicationController
  def create
    existing_users = User.where(email: params[:email])
    if existing_users.empty?
      @user = User.new(user_params)
      if @user.save
        authy = Authy::API.register_user(
            email: @user.email,
            cellphone: @user.phone_number,
            country_code: @user.country_code
        )
        @user.update(authy_id: authy.id)

        p authy
        p @user

        render json: {success: true }
      else
        render json: { success: false }
      end
    else
      render json: { duplicate_email: true }
    end
  end

  def new
    @user = User.new
  end

  private

  def user_params
    params.permit(:name, :email, :country_code, :phone_number, :password, :password_confirmation)
  end
end
