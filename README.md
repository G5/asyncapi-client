# Asyncapi::Client

Asyncapi::Client is a Rails engine that easily allows asynchronous communication with a Asyncapi::Server-based API server.

This avoids typing up your web servers executing long running processes. Scaling typically requires more workers.

# Usage

To communicate with the server (in the spirit of running things in the background, call the following from a worker):

```
Asyncapi::Client::Job.post(
  "http://server.com/long/running/process",
  # Options below are optional
  body: {info: "i want to send"},
  headers: { AUTHORIZATION: "Bearer XYZ" },
  on_success: DoOnSuccess,
  on_error: DoOnError,
  on_queue: DoOnQueue,
)
```

Each of the `on_*` classes will get executed. For example, when the job is queued on the server, `DoOnQueue.call` will get called with the `Asyncapi::Client::Job` instance passed in. Example:

```
class DoOnQueue
  def self.call(job)
    Rails.logger.info "Job##{job.id} successfully queued with body: #{job.body}"
  end
end

class DoOnSuccess
  def self.call(job)
    Rails.logger.info "Job##{job.id} is done. The server's response: #{job.message}"
  end
end

class DoOnError
  def self.call(job)
    Rails.logger.info "Job##{job.id} failed. The server's response: #{job.message}"
  end
end
```

Currently, this Engine only works with [Sidekiq](http://sidekiq.org), [typhoeus](https://github.com/typhoeus/typhoeus), and [kaminari](https://github.com/amatsuda/kaminari). Customizing these can be introduced as needed.

To run the application, you need to have the Sidekiq workers running as well.

There is a feed of all jobs that can be accessed via `/asyncapi/client/v1/jobs.json`. You can pass `per_page` and `page` to paginate through the records. Pagination is done by [api-pagination](https://github.com/davidcelis/api-pagination) via kaminari.

# Installation

## Required

Add the gem to the Gemfile:

```
gem "asyncapi-client"
```

From your Rails app:

```
rails g asyncapi:client:config
rake asyncapi_client:install:migrations
rake db:migrate
```

`Rails.application.routes.default_url_options[:host]` needs to be set

## Optional:

If you want to change the controller that the engine's controllers inherit from, from an initializer:

```
Asyncapi::Client.configure do |c|
  c.parent_controller = Api::BaseController
end
```

This project rocks and uses MIT-LICENSE.
