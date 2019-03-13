source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.2.2"

gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.3.1"
gem "eve_online"
gem "font-awesome-rails"
gem "icalendar"
gem "jbuilder", "~> 2.5"
gem "omniauth"
gem "omniauth-eve_online-sso"
gem "pg"
gem "pry-byebug"
gem "pry-rails"
gem "puma", "~> 3.11"
gem "sass-rails", "~> 5.0"
gem "sentry-raven"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get
  # a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker", git: "https://github.com/stympy/faker.git", branch: "master"
  gem "rspec-rails", "~> 3.8"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
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

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
