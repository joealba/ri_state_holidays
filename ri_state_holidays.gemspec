# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Joseph Alba"]
  gem.email         = ["jalba@egov.com"]
  gem.description   = %q{Calculate Rhode Island state holidays}
  gem.summary       = %q{Based off the Holidays Ruby gem -- but without altering the Date class}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ri_state_holidays"
  gem.require_paths = ["lib"]
  gem.version       = RiStateHolidays::VERSION

  gem.add_development_dependency "rspec", "~> 2.11.0"
end
