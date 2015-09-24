require "sidekiq"
require "sidekiq-cron"
require "api-pagination"
require "typhoeus"
require 'aasm'
require "asyncapi/client/engine"
require "securerandom"

module Asyncapi
  module Client

    CONFIG_ATTRS = [:parent_controller, :expiry_threshold]
    mattr_accessor(*CONFIG_ATTRS)
    self.expiry_threshold = 10.days

    def self.configure
      yield self
    end

    def self.parent_controller
      @@parent_controller || ActionController::Base
    end

  end
end
