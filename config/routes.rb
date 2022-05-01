Rails.application.routes.draw do
  root "pages#index"

  get "/", to: "pages#index"
  get "/about", to: "pages#about"

  get "/auth/eve_online_sso/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout
  get "/login", to: redirect("/auth/eve_online_sso"), as: :login
  get "/auth/failure", to: redirect("/")

  resource :onboarding, only: :show

  resource :secret_calendar, only: %i[show create]
  resource :public_calendar, only: %i[show update]

  resource :settings, only: %i[update]

  get "calendars/private-:id", to: "secret_feeds#show", as: :secret_feeds
  get "calendars/public-:id", to: "public_feeds#show", as: :public_feeds
end
