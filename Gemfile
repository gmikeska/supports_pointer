source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in supports_pointer.gemspec.
gemspec

gem "sqlite3"
group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Use sqlite3 as the database for Active Record
  # gem 'sqlite3', '~> 1.4'
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
      gem lib, git: "https://github.com/rspec/#{lib}.git", branch: 'main' # Previously '4-0-dev' or '4-0-maintenance' branch
  end
  gem 'rails-controller-testing'
  # gem 'pundit-matchers', '~> 1.7'
  gem 'pry', '~> 0.14.1'
  gem 'factory_bot_rails'

end
# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
