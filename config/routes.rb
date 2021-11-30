Rails.application.routes.draw do
  root "pages#index"

  get "/", to: "pages#index"
  get "/about", to: "pages#about"

  get "/auth/eve_online_sso/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout
  get "/login", to: redirect("/auth/eve_online_sso"), as: :login
  get "/auth/failure", to: redirect("/")

  resource :onboarding, only: :show

  resource :secret_token, only: %i[show create]

  resources :calendars,
    controller: :calendar_feeds,
    only: %i[show],
    as: :calendar_feeds
  resource :settings, only: %i[update]
  resource :sharing, only: %i[show update]
end
