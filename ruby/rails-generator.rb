# encoding: UTF-8

# 参考
# http://morizyun.github.io/blog/rails5-application-templates/index.html

# ==================
# GEMS
# ==================

gem 'mysql2'
gem 'rails-i18n'
gem 'whenever', require: false
gem 'slim-rails'
gem 'kaminari'
gem 'active_model_serializers'
gem 'webpacker'
gem 'sass-rails'
gem 'puma'
gem 'draper'
gem 'ransack'

# image
gem 'refile', require: 'refile/rails', github: 'manfe/refile'
gem 'refile-mini_magick'
gem 'refile-s3'

gem_group :development, :test do
  # Pry
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-state'
  gem 'pry-stack_explorer'

  # rspec
  gem 'rspec-rails'
  gem 'timecop'
  gem 'factory_girl_rails'
  gem "database_cleaner"

  # other
  gem 'rubocop'
  gem 'dotenv-rails'
  gem 'simplecov', require: false
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

# install gems
run 'bundle install --path vendor/bundle --jobs=4'

# devise
if yes? "Do you use devise?"
  gem "devise"
  generate "devise:install"
end

# convert erb file to slim
run 'bundle exec erb2slim -d app/views'


# install locales
remove_file 'config/locales/en.yml'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -P config/locales/'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"

# config/application.rb
application do
  %q{
    config.time_zone = 'Tokyo'
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.generators do |g|
      g.orm :active_record
      g.template_engine :slim
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.stylesheets false
      g.javascripts false
      g.assets false
      g.helper false
    end
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir['#{config.root}/lib/**/']
  }
end

# config/environments/development.rb
insert_into_file 'config/environments/development.rb', <<RUBY, after: 'config.assets.debug = true'

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
RUBY

# set up rubocop
create_file '.rubocop.yml', <<YAML
AllCops:
  Exclude:
    - 'vendor/**/*'
    - 'bin/*'
    - 'config/**/*'
    - 'Gemfile'
    - 'db/**/*'
    - 'spec/spec_helper.rb'
  RunRailsCops: true
  DisplayCopNames: true

Style/Documentation:
  Enabled: false
YAML

