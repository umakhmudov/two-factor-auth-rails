Rails.application.routes.draw do


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

end
