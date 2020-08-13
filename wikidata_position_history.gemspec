# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikidata_position_history/version'

Gem::Specification.new do |spec|
  spec.name          = 'wikidata_position_history'
  spec.version       = WikidataPositionHistory::VERSION
  spec.authors       = ['Tony Bowden', 'Mark Longair']
  spec.email         = ['team@everypolitician.org']

  spec.summary       = 'Generates a wikitext history of a holders of a position in Wikidata'
  spec.homepage      = 'https://github.com/everypolitician/wikidata-position-history/'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mediawiki-page-replaceable_content', '0.1.3'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'reek', '~> 6.0'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
  spec.add_development_dependency 'webmock', '~> 3.0.0'
end
