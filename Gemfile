source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.4"

gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.6.0"
gem "daemons"
gem "delayed_job_active_record"
gem "eve_online"
gem "icalendar"
gem "jbuilder", "~> 2.11"
gem "omniauth", "~> 2.0"
gem "omniauth-eve_online-sso"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "pg"
gem "pry-rails"
gem "puma", "~> 5.6"
gem "rack-timeout"
gem "sass-rails", "~> 6.0"
gem "sentry-ruby"
gem "sentry-rails"
gem "skylight"
gem "turbolinks", "~> 5"
gem "tzinfo-data"
gem "uglifier", ">= 1.3.0"
gem "webpacker"

group :development, :test do
  gem "break"
  gem "climate_control"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", ">= 4.0.0.beta3"
  gem "standard", require: false
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.8"
  gem "poro-rails"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "chromedriver-helper"
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end
