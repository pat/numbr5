require 'jeweler'
require 'yard'

YARD::Rake::YardocTask.new

Jeweler::Tasks.new do |gem|
  gem.name        = 'numbr5'
  gem.summary     = 'Number 5: Universal Thanking Bot'
  gem.description = 'A multi-server bot that tracks thanks between accounts'
  gem.email       = 'pat@freelancing-gods.com'
  gem.homepage    = 'http://github.com/freelancing-god/numbr5'
  gem.authors     = ['Pat Allan']
  
  gem.files       = FileList[
    'bin/*',
    'lib/**/*.rb',
    'LICENSE',
    'README.textile',
    'VERSION'
  ]
  gem.test_files  = FileList[
    'config/*',
    'spec/**/*.rb'
  ]
  
  gem.add_dependency 'eventmachine', '>= 0.12.8'
  gem.add_dependency 'rest-client',  '>= 1.0.3'
  gem.add_dependency 'json',         '>= 1.1.9'
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'

  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end
