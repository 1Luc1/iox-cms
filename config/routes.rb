Ion::Engine.routes.draw do

  get '/login', to: 'auth#login'
  get '/login', to: 'auth#unauthenticated'
  post '/login', to: 'auth#login'
  get '/logout', to: 'auth#logout'
  get '/a/f_pwd', to: 'auth#forgot_password'
  post '/a/f_pwd', to: 'auth#forgot_password'
  get '/a/r_pwd', to: 'auth#reset_password'
  post '/a/r_pwd', to: 'auth#reset_password'
  get '/a/c_pwd/:id', to: 'auth#change_password', as: 'change_password'
  post '/a/c_pwd/:id', to: 'auth#save_password', as: 'save_password'

  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  get '/dashboard/quota', to: 'dashboard#quota'
  get '/activities/summary', to: 'activities#summary'
  get '/activities', to: 'activities#index'

  resources :users do
    member do
      post 'upload_avatar'
      delete 'avatar'
    end
  end

  resources :webpages do
    collection do
      get 'images'
      get 'by_slug'
    end
    member do
      post 'preview'
      put 'publish'
      get 'frontpage'
      post 'restore'
      post 'reorder'
    end
  end

end
