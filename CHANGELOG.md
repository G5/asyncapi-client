# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.5.0] - 2016-03-31
### Added
- Relax Rails version to ~> 4.1
- Do not use `responders` gem in controller. Lessen dependencies

### Fixed
- Remove warning about circular dependencies

## [0.4.0]
### Changed
- Use `sidekiq-cron` for scheduling.

## [0.3.0]
### Added
- Add `Asyncapi::Client::Job#response_code`
- Add Job `fail_queue` event that transitions from `fresh` to `queue_error`
- Remove unneeded scope for `Job.for_time_out`. Has a small speed increase.
- Scope `Job.for_time_out` to `fresh` and `queued` statuses because it's not possible to transition to `timed_out` from other statuses.

### Changed
- Unsuccessful response in JobPostWorker triggers `fail_queue` event

## [0.2.0]
### Added
- Mention that `:status` is one of the attributes that should be allowed during mass assignment when using `protected_attributes`
- Use a secret generated in the client for the server to negotiate authentication
  - No more manual authentication needs to be done. Ensure that the `Asyncapi::Client.parent_controller` config is removed
- Add `on_time_out` callback

### Changed
- By default, jobs will not time out. `time_out` must be supplied
- Trigger `JobStatusWorker` when server responds with an error
- The `JobTimeOutWorker` that checks for jobs that should be timed out runs every minute

## [0.1.0]
### Added
- Add `Asyncapi::Client::Job#callback_params` for params that will be accessible by the callback runners

### Changed
- Callback runners must inherit from `Asyncapi::Client::CallbackRunner`. See README for an example.

### Fixed
- Fixes issue when setting callbacks that are constants/classes

## [0.0.1]
### Added
- Initial working version
