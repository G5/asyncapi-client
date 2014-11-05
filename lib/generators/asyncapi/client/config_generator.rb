require "asyncapi/client/engine"

module Asyncapi::Client
  class ConfigGenerator < Rails::Generators::Base

    desc "Inserts routes code for Asyncapi::Client"

    def mount_on_routes
      inject_into_file(
        "config/routes.rb",
        %Q(  mount Asyncapi::Client::Engine, at: "/asyncapi/client"\n),
        before: /^end/
      )
    end

  end
end
