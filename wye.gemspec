$:.push File.expand_path('../lib', __FILE__)

require 'wye/version'

Gem::Specification.new do |s|
  s.name = 'wye'
  s.summary = 'Simple contextual switching of ActiveRecord connection pools.'
  s.description = (<<-end_).split.join(' ')
    Wye provides users of ActiveRecord 3.2 with scopes and block methods for contextual execution
    of database queries on alternative database connections. Wye's patterns are most useful to
    applications making use of either replicated or federated databases.
  end_

  s.platform = Gem::Platform::RUBY
  s.authors = ['Daniel Duvall']
  s.email = ['dan@mutual.io']
  s.homepage = 'https://github.com/lettersandlight/wye'

  s.files = Dir['{lib}/**/*'] + ['MIT-LICENSE', 'Gemfile', 'README.rdoc']
  s.version = Wye::VERSION

  s.require_paths = ['lib']

  s.add_runtime_dependency 'activerecord', '~> 3.2.8'

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'shoulda-matchers', '~> 1.1'
end
