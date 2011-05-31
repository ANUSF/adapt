Adapt::Application.routes.draw do
  devise_for :user_accounts, :controllers => { :sessions => "sessions" } do
    get "login",  :to => "sessions#new"
    get "logout", :to => "sessions#destroy"
  end

  devise_scope :user_account do
    resources :sessions
  end

  namespace :adapt do
    resources :studies do
      member do
        post 'approve'
        post 'manage'
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
