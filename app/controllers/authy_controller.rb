require 'openssl'
require 'base64'

class AuthyController < ApplicationController
    # Before we allow the incoming request to callback, verify
    # that it is an Authy request
    before_filter :authenticate_authy_request, :only => [
        :callback
    ]

    protect_from_forgery except: [:callback, :one_touch_status]

    def callback
      authy_id = params[:authy_id]
      begin
        @user = User.find_by! authy_id: authy_id
        @user.update(authy_status: params[:status])
      rescue => e
        puts e.message
      end
      render plain: 'OK'
    end

    def one_touch_status
      require 'cgi'
      require 'json'

      @user = User.find(session[:pre_2fa_auth_user_id])
      uri = URI('https://api.authy.com/onetouch/json/approval_requests/'+@user.uuid)

      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri
        request["X-Authy-API-Key"] = Authy.api_key
        @res = http.request request # Net::HTTPResponse object
      end

      response = JSON.parse(@res.body)
      new_status = response['approval_request']['status']
      @user.update(authy_status: new_status)
      session[:user_id] = @user.authy_approved? ? @user.id : nil
      render plain: new_status
    end

    def verify_soft_token
      result_msg = { success: false}
      @user = User.find(session[:pre_2fa_auth_user_id])
      token = Authy::API.verify(id: @user.authy_id, token: params[:token])
      if token.ok?
        session[:user_id] = @user.id
        session[:pre_2fa_auth_user_id] = nil
        result_msg[:success] = true
      end
      render json: result_msg
    end

    # Authenticate that all requests to our public-facing callback is
    # coming from Authy. Adapted from the example at
    # https://docs.authy.com/new_doc/authy_onetouch_api#authenticating-callbacks-from-authy-onetouch
    private
    def authenticate_authy_request
      url = request.url
      raw_params = JSON.parse(request.raw_post)
      nonce = request.headers["X-Authy-Signature-Nonce"]
      sorted_params = (Hash[raw_params.sort]).to_query

      # data format of Authy digest
      data = nonce + "|" + request.method + "|" + url + "|" + sorted_params

      digest = OpenSSL::HMAC.digest('sha256', Authy.api_key, data)
      digest_in_base64 = Base64.encode64(digest)

      theirs = (request.headers['X-Authy-Signature']).strip
      mine = digest_in_base64.strip

      unless theirs == mine
        render plain: 'invalid request signature'
      end
    end
end
