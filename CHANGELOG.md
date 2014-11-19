# 0.1.0

- Add `Asyncapi::Client::Job#callback_params` for params that will be accessible by the callback runners
- Callback runners must inherit from `Asyncapi::Client::CallbackRunner`. See README for an example.
- Fixes issue when setting callbacks that are constants/classes

# 0.0.1

- Initial working version
