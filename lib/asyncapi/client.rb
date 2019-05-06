require "sidekiq"
require "sidekiq-cron"
require "api-pagination"
require "typhoeus"
require 'aasm'
require 'ar_after_transaction'
require "asyncapi/client/engine"
require "securerandom"

module Asyncapi
  module Client

    CONFIG_ATTRS = %i[parent_controller expiry_threshold clean_job_cron succeeded_job_deletion_threshold]
    mattr_accessor(*CONFIG_ATTRS)
    self.expiry_threshold = 4.days
    self.succeeded_job_deletion_threshold = 2.minutes
    self.clean_job_cron = "0 0 * * *"

    def self.configure
      yield self
    end

    def self.parent_controller
      @@parent_controller || ActionController::Base
    end

  end
end
