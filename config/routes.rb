Asyncapi::Client::Engine.routes.draw do
  namespace :v1 do
    resources :jobs
  end
end
