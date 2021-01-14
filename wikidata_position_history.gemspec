# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikidata_position_history/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.5.0'
  spec.name                  = 'wikidata_position_history'
  spec.version               = WikidataPositionHistory::VERSION
  spec.authors               = ['Tony Bowden', 'Mark Longair']
  spec.email                 = ['tony@tmtm.com']

  spec.summary  = 'Generates a table of historic holders of a Wikidata position'
  spec.homepage = 'https://github.com/tmtmtmtm/wikidata-position-history/'
  spec.license  = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mediawiki-replaceable-content', '0.2.2'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'reek', '~> 6.0'
  spec.add_development_dependency 'rubocop', '~> 0.89'
  spec.add_development_dependency 'rubocop-performance', '~> 1.9.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.44.1'
  spec.add_development_dependency 'warning', '~> 1.1'
  spec.add_development_dependency 'webmock', '~> 3.11.1'
end
