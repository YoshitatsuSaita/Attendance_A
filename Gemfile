source "https://rubygems.org"


ruby "3.0.6"
gem "rails", "~> 7.1.0"
gem 'bcrypt'
gem 'faker'
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]
gem "bootsnap", require: false
gem "sassc-rails"
gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.3'                                                                                                                          
gem 'bootstrap-will_paginate', '1.0.0'  
gem 'rails-i18n'


group :production do
  gem "pg", "~> 1.1"
end

group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
end


group :development do
  gem "web-console"
  gem "listen"
  gem "mysql2"
end


group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'rails-flog', require: 'flog'
  gem 'rspec-rails'
  gem "factory_bot_rails"
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end