# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Joe Alba"]
  gem.email         = ["joe@joealba.com"]
  gem.description   = %q{Calculate Rhode Island state holidays}
  gem.summary       = %q{Based off the Holidays Ruby gem -- but without altering the Date class}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['ri_state_holiday']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ri_state_holidays"
  gem.require_paths = ["lib"]

  gem.version       = '0.1.1'

  gem.add_development_dependency "rspec", ">= 3.0.0"
  gem.add_development_dependency "rake"
end
