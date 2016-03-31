# Asyncapi::Client

Asyncapi::Client is a Rails engine that easily allows asynchronous communication with a [Asyncapi::Server](https://github.com/G5/asyncapi-server)-based API server.

This avoids tying up your web servers executing long running processes. Scaling typically requires more workers.

# Usage

To communicate with the server (in the spirit of running things in the background, call the following from a worker):

```ruby
Asyncapi::Client::Job.post(
  "http://server.com/long/running/process",
  # Options below are optional
  body: {info: "i want to send"},
  headers: { AUTHORIZATION: "Bearer XYZ" },
  on_success: DoOnSuccess,
  on_error: DoOnError,
  on_queue: DoOnQueue,
  on_queue_error: DoOnQueueError,
  on_time_out: DoOnTimeOut,
  time_out: 2.minutes # Defaults to nil (never time out)
)
```

*Jobs that should be timed out are marked as `timed_out` approximately every minute.*

Each of the `on_*` classes will get executed. For example, when the job is queued on the server, `DoOnQueue#call` will get called with the `Asyncapi::Client::Job` instance passed in. Example:

```ruby
class DoOnQueue < Asyncapi::Client::CallbackRunner
  def call
    # you have access to: job, callback_params
    Rails.logger.info "Job##{job.id} successfully queued with body: #{job.body}"
  end
end

class DoOnSuccess < Asyncapi::Client::CallbackRunner
  def call
    Rails.logger.info "Job##{job.id} is done. The server's response: #{job.message}"
  end
end

class DoOnError < Asyncapi::Client::CallbackRunner
  def call
    # you have access to: job and its fields: callback_params, :body, :headers, :message, :response_code
    Rails.logger.info "Job##{job.id} failed. The server's response: #{job.message}"
  end
end
```

In the callback classes, you have access to the `job` and its fields (directly):

- `callback_params`
- `body`
- `headers`
- `message`
- `response_code`

Currently, this Engine only works with [Sidekiq](http://sidekiq.org), [typhoeus](https://github.com/typhoeus/typhoeus), and [kaminari](https://github.com/amatsuda/kaminari). Customizing these can be introduced as needed.

To run the application, you need to have the Sidekiq workers running as well.

There is a feed of all jobs that can be accessed via `/asyncapi/client/v1/jobs.json`. You can pass `per_page` and `page` to paginate through the records. Pagination is done by [api-pagination](https://github.com/davidcelis/api-pagination) via kaminari.

## Expiry

To make space in the database, old jobs must be deleted. By default, jobs older than 10 days will be deleted in both the Asyncapi Client and Asyncapi Server. Asyncapi Client is responsible for deleting the jobs it no longer needs a response from on the server.

By default, jobs 10 days old and older will be deleted. You can change this setting by putting this in an initializer:

```ruby
Asyncapi::Client.expiry_threshold = 5.days
```

If you don't ever want the jobs to get delete, set the threshold to `nil`.

# Installation

**Note**: if you're using the `protected_attributes`, also see the "Optional" section below.

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

Make sure you have `:host` in the `default_url_options` set up for your server. Example `config/initializers/default_url_options.rb`:

```ruby
Rails.application.routes.default_url_options ||= {}
Rails.application.routes.default_url_options[:host] = ENV["HOST"]
```

## Optional:

If you want to change the controller that the engine's controllers inherit from, from an initializer:

```
Asyncapi::Client.configure do |c|
  c.parent_controller = Api::BaseController
end
```

If you use `protected_attributes`, you need to whitelist attributes. In an initializer:

```ruby
Asyncapi::Client::Job.attr_accessible(
  :follow_up_at,
  :time_out_at,
  :on_queue,
  :on_success,
  :on_error,
  :on_queue_error,
  :headers,
  :body,
  :status,
  :response_code,
)
```

If you use FactoryGirl, you can require the factories for easy testing and stubbing:

```ruby
require "asyncapi/client/factories"
```

## Security

`asyncapi-client` generates a secret for the job using `SecureRandom.uuid`, and sends this to the app using `asyncapi-server`. The server app, using the latest compatible gem, will reply with the secret in the params. `asyncapi-client` will make sure the job id matches with the given secret.

## License

Copyright (c) 2014 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
