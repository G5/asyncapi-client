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

    CONFIG_ATTRS = %i[parent_controller expiry_threshold clean_job_cron successful_jobs_deletion_after]
    mattr_accessor(*CONFIG_ATTRS)
    self.expiry_threshold = 4.days
    self.successful_jobs_deletion_after = 2.minutes
    self.clean_job_cron = "0 0 * * *"

    def self.configure
      yield self
    end

    def self.parent_controller
      @@parent_controller || ActionController::Base
    end

  end
end
