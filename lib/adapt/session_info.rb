module Adapt::SessionInfo
  def current_user
    Thread.current[:user]
  end

  def self.current_user=(user)
    Thread.current[:user] = user
  end

  def request_host
    Thread.current[:host]
  end

  def self.request_host=(host)
    Thread.current[:host] = host
  end
end
