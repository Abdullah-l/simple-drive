Rails.application.routes.draw do
  namespace :v1 do
    resources :blobs, only: %i[create show]
  end
end
