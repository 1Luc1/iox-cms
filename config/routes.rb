Iox::Engine.routes.draw do

  get '/login', to: 'auth#login'
  get '/login', to: 'auth#unauthenticated'
  post '/login', to: 'auth#login'
  get '/logout', to: 'auth#logout'
  get '/forgot_password', to: 'auth#forgot_password'
  post '/forgot_password', to: 'auth#forgot_password'
  get '/reset_password/:id', to: 'auth#reset_password'
  post '/reset_password/:id', to: 'auth#reset_password', as: 'reset_password'
  get '/welcome/:id', to: 'auth#set_password'
  get '/a/c_pwd/:id', to: 'auth#change_password', as: 'change_password'
  patch '/a/c_pwd/:id', to: 'auth#save_password', as: 'save_password'

  get '/dashboard', to: 'dashboard#index', as: 'dashboard'
  get '/dashboard/quota', to: 'dashboard#quota'
  get '/activities/summary', to: 'activities#summary'
  get '/activities', to: 'activities#index'

  resources :users do
    member do
      get 'confirmation_qr'
      get 'confirm_suspend'
      patch 'suspend'
      patch 'unsuspend'
      get 'confirm_delete'
      post 'upload_avatar'
      delete 'avatar'
    end
    collection do
      get 'register'
      post 'register'
    end
  end

  resources :webfiles
  
  resources :webpages do

    resources :translations
    resources :webfiles
    resources :webbits

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
      get 'images'
      delete 'delete_webbit_from'
    end
  end

end
