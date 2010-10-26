Adapt::Application.routes.draw do
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

  match 'login', :to => 'adapt/user_sessions#new'
  match 'logout', :to => 'adapt/user_sessions#destroy'

  root :to => 'adapt/user_sessions#new'
end
