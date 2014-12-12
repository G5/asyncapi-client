require "sidekiq"
require "api-pagination"
require "typhoeus"
require "asyncapi/client/engine"
require "securerandom"

module Asyncapi
  module Client

    CONFIG_ATTRS = [:parent_controller]
    mattr_accessor(*CONFIG_ATTRS)

    def self.configure
      yield self
    end

    def self.parent_controller
      @@parent_controller || ActionController::Base
    end

  end
end
