# encoding: UTF-8

# 参考
# http://morizyun.github.io/blog/rails5-application-templates/index.html

# ==================
# GEMS
# ==================

# if yes? 'Do you want to use Heroku?'
#   gem_group :production do
#     gem 'rails_12factor'
#   end
# end

gem 'rails-i18n'
gem 'whenever', require: false
gem 'slim-rails'
gem 'kaminari'
gem 'active_model_serializers'
gem 'fast_jsonapi' #https://github.com/Netflix/fast_jsonapi
gem 'webpacker'
gem 'sass-rails'
gem 'puma'
gem 'draper'
gem 'ransack'
gem 'mysql2'
gem 'toastr_rails'
gem 'font-awesome-rails'
gem 'redis'
gem 'redis-rails'
gem 'view_source_map'
gem 'enumerize'
gem 'rufo'

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
  gem "pry-coolline"
  gem "pry-byebug"
  gem 'pry-stack_explorer'
  gem "hirb"
  # gem "hirb-unicode"

  # rspec
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'webmock'
  gem 'timecop'
  gem 'factory_bot_rails'
  gem "database_cleaner"
  gem 'vcr'
  gem 'database_rewinder'
  gem 'capybara'
  gem 'selenium-webdriver'

  # other
  gem 'rubocop', '~> 0.49.0'
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
  gem 'bundler-audit'
  gem 'brakeman'
  gem 'rack-mini-profiler'
  gem 'rufo'
  # guard
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'spring-commands-rspec'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'
  gem 'capistrano3-unicorn'
end

# devise
if yes? "Do you use devise?"
  gem "devise"
end

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
    config.i18n.default_locale = :ja
    config.generators do |g|
      g.orm :active_record
      g.template_engine :slim
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
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
# 謎な一行が大事！この一行がないとシンタックスエラー起こす
insert_into_file 'config/environments/development.rb', after: 'config.assets.debug = true' do
  <<~RUBY

    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.console = false
      Bullet.add_footer = false
      Bullet.rails_logger = true
    end
  RUBY
end

create_file 'config/initializers/active_model_serializers.rb', <<RUBY
ActiveModel::Serializer.config.adapter = :json
RUBY

create_file '.rufo', <<-EOF
indent_size                 2
spaces_inside_hash_brace    :always
spaces_inside_array_bracket :never
spaces_around_equal         :one
spaces_in_ternary           :one
spaces_in_suffix            :one
spaces_in_commands          :dynamic
spaces_around_block_brace   :one
spaces_after_comma          :dynamic
spaces_around_hash_arrow    :one
spaces_around_when          :one
spaces_around_dot           :no
spaces_after_lambda_arrow   :no
spaces_around_unary         :no
spaces_around_binary        :one
parens_in_def               :yes
double_newline_inside_type  :no
visibility_indent           :align
trailing_commas             :never
align_comments              true
align_assignments           true
align_hash_keys             true
align_case_when             true
align_chained_calls         true
EOF

run 'rm -rf test'
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
Rails:
  Enabled: true
Style/Documentation:
  Enabled: false
Style/FrozenStringLiteralComment:
  Enabled: false
Style/AsciiComments:
  Enabled: false
Style/PercentLiteralDelimiters:
  Enabled: false
inherit_from: .rubocop_todo.yml
YAML

run "cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*.log
/tmp
database.yml
doc/
/vendor/bundle
/coverage
*.swp
*~
.project
.idea
.secret
.DS_Store
EOF"

create_file '.pryrc', <<RUBY
# awesome_print
begin
  require "awesome_print"
  Pry.config.print = proc { |output, value| output.puts value.ai }
rescue LoadError
  puts "no awesome_print :("
end

# hirb
begin
  require "hirb"
rescue LoadError
  puts "no hirb :("
end

if defined? Hirb
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end
RUBY

# dotenv-rails
run 'touch .env'

create_file '.ruby-version', <<EOF
2.4.1
EOF

run_bundle

after_bundle do
  run 'bundle exec spring stop'

  # setting
  run 'bundle update'

  # ===================
  # Setting Rspec
  # ===================
  run 'bundle exec rails g rspec:install'

  insert_into_file 'spec/spec_helper.rb', before: 'RSpec.configure do |config|' do
    <<~RUBY

      require 'factory_bot_rails'
      require 'vcr'
      require 'simplecov'
      require "webmock/rspec"
      require 'database_cleaner'
      SimpleCov.start 'rails'

    RUBY
  end

  insert_into_file 'spec/spec_helper.rb', after: 'RSpec.configure do |config|' do
    <<~RUBY

      config.before(:each) do
        DatabaseCleaner.start
      end

      config.after(:each) do
        DatabaseCleaner.clean
      end

      config.before :all do
        FactoryBot.reload
        FactoryBot.factories.clear
        FactoryBot.sequences.clear
        FactoryBot.find_definitions
      end

      config.include FactoryBot::Syntax::Methods

      VCR.configure do |c|
        c.cassette_library_dir = 'spec/vcr'
        c.hook_into :webmock
        c.allow_http_connections_when_no_cassette = true
      end
    RUBY
  end

  # setting kaminari
  run 'bundle exec rails g kaminari:config'

  # Initialize guard
  run "bundle exec guard init rspec"
  # convert erb file to slim
  run 'bundle exec erb2slim -d app/views'

  # setting whenever
  run 'bundle exec wheneverize .'

  run 'bundle exec cap install'

  # 参考 https://qiita.com/ktsujichan/items/2899d337ecbd90474c46
  run 'mkdir app/services'
  run 'mkdir app/tasks'
  run 'mkdir app/serializers'
  run 'mkdir app/callbacks'
  run 'mkdir app/exceptions'
  run 'mkdir app/utils'
  run 'mkdir app/validators'
  run 'mkdir app/notifiers'
  run 'mkdir app/forms'

  # setting frontend
  front_resorce = ask("choise front-end 'none:1' or 'react:2' ")
  case front_resorce
  when '1'
    return
  when '2'
    run 'bundle exec rails webpacker:install'
    run 'bundle exec rails webpacker:install:react'
  else
    return
  end

  run "bundle exec rubocop -a --auto-gen-config"

  run 'bundle exec spring binstub --all'
end

if yes? "Do you delete .git/?"
  run 'rm -rf .git/'
else
  after_bundle do
    git :init
    git add: "."
    git commit: %Q{ -m 'Initial Settings' }
  end
end
