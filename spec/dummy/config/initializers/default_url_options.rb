Rails.application.routes.default_url_options ||= {}
Rails.application.routes.default_url_options[:host] = "#{Rails.env}.com"
