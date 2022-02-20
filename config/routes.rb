Rails.application.routes.draw do
  root "pages#index"

  get "/", to: "pages#index"
  get "/about", to: "pages#about"

  get "/auth/eve_online_sso/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout
  get "/login", to: redirect("/auth/eve_online_sso"), as: :login
  get "/auth/failure", to: redirect("/")

  resource :onboarding, only: :show

  resource :private_access, only: %i[show create]
  resource :public_access, only: %i[show update]

  resources :calendars,
    controller: :calendar_feeds,
    only: %i[show],
    as: :calendar_feeds
  resource :settings, only: %i[update]
end
