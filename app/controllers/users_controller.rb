class UsersController < ApplicationController
  def create
    existing_users = User.where(email: params[:email])
    if existing_users.empty?
      @user = User.new(user_params)
      if @user.save
        uri = URI('https://api.authy.com/protected/json/users/new?user[email]='+params[:email]+'&user[cellphone]='+params[:phone_number]+'&user[country_code]='+params[:country_code])

        p Authy.api_key

        Net::HTTP.start(uri.host, uri.port,
                        :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Post.new uri
          request["X-Authy-API-Key"] = Authy.api_key
          @res = http.request request # Net::HTTPResponse object
        end

        response = JSON.parse(@res.body)
        p response

        if response['success']
          @user.update(authy_id: response['user']['id'])
          render json: {success: true }
        else
          render json: { success: false }
        end
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
