source "http://rubygems.org"
gemspec

rails = ENV['RAILS'] || 'master'

case rails
when /\// # A path
  path rails do
    gem 'activerecord'
  end
when /^v/ # A tagged version
  git 'git://github.com/rails/rails.git', :tag => rails do
    gem 'activerecord'
  end
else
  git 'git://github.com/rails/rails.git', :branch => rails do
    gem 'activerecord'
  end
end