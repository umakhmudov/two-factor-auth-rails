Rails.application.routes.draw do

  #set home page as the authenticated view
  root 'main#index'

  # sign up page
  get '/signup' => 'users#new'

  # user creation (signup)
  post '/users' => 'users#create'

  #login page
  get '/login' => 'sessions#new'

  #session creation(login)
  post '/login' => 'sessions#create'

  #session destroy (logout)
  get '/logout' => 'sessions#destroy'

  # authy POST callback
  post "authy/callback" => 'authy#callback'

  #authy status check for one-touch verification
  get "authy/status" => 'authy#one_touch_status'

  #authy verify entered soft token
  post "authy/verify_soft_token"

end
