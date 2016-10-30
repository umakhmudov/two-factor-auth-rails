Rails.application.routes.draw do


  # sign up page route
  get '/signup' => 'users#new'

  # user creation route
  post '/users' => 'users#create'

end
