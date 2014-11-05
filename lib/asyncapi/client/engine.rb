module Asyncapi
  module Client
    class Engine < ::Rails::Engine
      isolate_namespace Asyncapi::Client
      engine_name "asyncapi_client"

      config.to_prepare do
        Dir.glob(Engine.root + "app/workers/**/*.rb").each do |c|
          require_dependency(c)
        end

        Engine.routes.default_url_options =
          Rails.application.routes.default_url_options
      end

    end
  end
end
