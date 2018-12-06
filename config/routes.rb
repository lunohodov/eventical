Rails.application.routes.draw do
  get "/", to: "pages#index"

  resources :character do
    resource :calendar
  end
end
