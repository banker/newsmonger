ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :comments, :member => {:upvote => :post}
  map.resources :stories,  :member => {:upvote => :post}
  map.resource  :session

  map.root :controller => 'stories', :action => 'index'

  map.signin '/signin', :controller => 'sessions', :action => 'new'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
