Adapt::Application.routes.draw do
  resources :user_sessions
  resources :users

  resources :studies do
    member do
      post 'approve'
      post 'store'
      post 'submit'
    end
  end

  resources :attachments do
    get 'download', :on => :member
  end

  resources :licences do
    post 'accept', :on => :member
  end

  match 'login', :to => 'user_sessions#new'
  match 'logout', :to => 'user_sessions#destroy'

  root :to => 'user_sessions#new'
end
