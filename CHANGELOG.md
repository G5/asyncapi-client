# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## TBD [0.9.0-alpha.1] - 2019-05-05
### Added
- Added `successful_jobs_deletion_after` configuration option to set the time after a succeeded job should be deleted.
- Jobs now schedule a cleanup job to delete themselves in `successful_jobs_deletion_after`-time after succees.

### Changed
- Replaced occurrences of `have_enqueued_job` to `have_enqueued_sidekiq_job` in specs to avoid deprecation notices and name clashes with ActiveJob.

## [0.8.1] - 2019-03-04
### Removed
- Removed index to jobs table on `expired_at` attribute, with so many updates, it is non performant.

## [0.8.0] - 2019-02-18
### Changed
- Fixes jobs deletion in cleanup when there are remote job parameters missing.
- Add a more efficient way to retrieve jobs for cleanup.
- Update migrations to be Rails 5 compliant.
### Added
- Add index to jobs table on `expired_at` attribute.

## [0.7.0] - 2018-04-03
### Changed
- Update ruby to 2.3.1
- Requires a Rails 5 compatible application
- Remove `job#body=` method to allow for a more agnostic use
### Added
- Use `head` for header only responses

## [0.6.2] - 2018-01-11
### Changed
- Transform params into json format if data type is a Hash.

## [0.6.1] - 2016-08-02
### Fixed
- Wait for db transaction to complete before enqueuing job

## [0.6.0] - 2016-05-27
### Changed
- Cleaner worker is scheduled to run every day instead of every time a job is created

## [0.5.1] - 2016-05-18
### Fixed
- [Do not include redis immediately](https://github.com/G5/asyncapi-client/pull/20)

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
