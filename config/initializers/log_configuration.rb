text = ADAPT::CONFIG.map { |k,v| "#{k} => #{v}" }.join("\n      ")
if defined?(JRUBY_VERSION) && defined?($servlet_context)
  # -- apparently too early to use Rails.logger
  $servlet_context.log text
else
  Rails.logger.info(text)
end
