ActionController::Routing::Routes.draw do |map|
  map.resources :user_sessions
  map.resources :users
  map.resources :studies, :shallow => true,
                :member => { :submit  => :post,
                             :approve => :post } do |studies|
    studies.resources :attachments, :member => { :download => :get }
  end
  map.resources :study_data
  map.resources :study_acknowledgements

  map.login "login", :controller => 'user_sessions', :action => 'new'
  map.logout "logout", :controller => 'user_sessions', :action => 'destroy'

  map.root :login
end
