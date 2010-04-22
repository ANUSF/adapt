ActionController::Routing::Routes.draw do |map|
  map.resources :user_sessions
  map.resources :users
  map.resources :studies, :shallow => true,
                :member => { :approve => :post,
                             :reject  => :post,
                             :submit  => :post } do |studies|
    studies.resources :attachments, :member => { :download => :get }
    studies.resources :licences, :member => { :accept => :post }
  end

  map.login "login", :controller => 'user_sessions', :action => 'new'
  map.logout "logout", :controller => 'user_sessions', :action => 'destroy'

  map.root :login
end
