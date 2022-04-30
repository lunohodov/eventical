Rails.application.routes.draw do
  root "pages#index"

  get "/", to: "pages#index"
  get "/about", to: "pages#about"

  get "/auth/eve_online_sso/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout
  get "/login", to: redirect("/auth/eve_online_sso"), as: :login
  get "/auth/failure", to: redirect("/")

  resource :onboarding, only: :show

  resource :public_access, only: %i[show update]

  resource :secret_calendar, only: %i[show create]

  # resource :public_calendar
  #
  # resource :secret_calendar_feed
  # resource :public_calendar_feed

  # get "calendars/private-:id", to: "secret_calendar_feeds#show", as: :secret_calendar_feeds
  resources :calendars,
    controller: :calendar_feeds,
    only: %i[show],
    as: :calendar_feeds
  resource :settings, only: %i[update]
end
