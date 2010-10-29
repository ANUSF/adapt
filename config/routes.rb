Adapt::Application.routes.draw do
  devise_for :user_accounts do
    get "login",  :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  namespace :adapt do
    resources :user_sessions
    
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
  end

  root :to => 'adapt/studies#index'
end
