# encoding: UTF-8


# ==================
# GEMS
# ==================

gem 'mysql2'
gem "rails-i18n"
gem 'whenever', require: false
gem 'slim-rails'
gem 'kaminari'
gem 'active_model_serializers'
gem 'webpacker', github: 'rails/webpacker'
gem 'sass-rails'
gem 'puma'
gem 'draper'

gem_group :development, :test do
  # Pry
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-state'
  gem 'pry-stack_explorer'

  # rspec
  gem "rspec-rails"
  gem 'timecop'
  gem "factory_girl_rails"

  # other
  gem 'rubocop'
  gem 'dotenv-rails'
  gem "simplecov", require: false
end

gem_group :development, :staging do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
end

gem_group :development do
  gem 'html2slim'
  gem 'xray-rails'
  gem 'view_source_map'
end
