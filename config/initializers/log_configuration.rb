Rails.logger.info ADAPT::CONFIG.map { |k,v| "#{k} => #{v}" }.join("\n      ")
