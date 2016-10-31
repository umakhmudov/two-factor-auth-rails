class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:email])
    # if the user is present and password is correct
    if @user && @user.authenticate(params[:password])
      #save to session variable
      session[:pre_2fa_auth_user_id] = @user.id
      # Try to verify with OneTouch
      one_touch = Authy::OneTouch.send_approval_request(
          id: @user.authy_id,
          message: "Request to login to TwoFactorAuthRails",
          details: {
              'Email Address' => @user.email,
          }
      )

      status = one_touch['success'] ? 'onetouch' : 'softtoken'
      uuid = one_touch['approval_request'] ? one_touch['approval_request']['uuid'] : nil

      @user.update(authy_status: status, uuid: uuid)

      # Respond to the ajax call that requested this with the approval request body
      render json: { success: one_touch['success'] }
    else
      render json: { invalid_credentials: true }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/login'
  end
end
