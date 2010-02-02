require 'pickle/world'

Pickle.configure do |config|
  config.adapters = [:machinist]
  config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
  config.map 'they', 'themselves', 'them', 'their',
             :to => 'user: "them"'
end
