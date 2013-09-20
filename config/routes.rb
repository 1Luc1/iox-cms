Ion::Engine.routes.draw do

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

  get '/login', to: 'auth#login'
  get '/login', to: 'auth#unauthenticated'
  post '/login', to: 'auth#login'
  get '/logout', to: 'auth#logout'
  get '/forgot_password', to: 'auth#forgot_password'
  post '/forgot_password', to: 'auth#forgot_password'
  get '/reset_password', to: 'auth#reset_password'
  post '/reset_password', to: 'auth#reset_password'

  get '/dashboard', to: 'dashboard#index', as: 'dashboard'

end
