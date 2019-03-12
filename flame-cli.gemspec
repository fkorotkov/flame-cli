# frozen_string_literal: true

Gem::Specification.new do |s|
	s.name        = 'flame-cli'
	s.version     = '0.0.0'

	s.summary     = 'CLI for Flame Web-framework'
	s.description = 'Generate new application and maybe something else.'

	s.authors     = ['Alexander Popov']
	s.email       = ['alex.wayfer@gmail.com']
	s.homepage    = 'https://github.com/AlexWayfer/flame-cli'
	s.license     = 'MIT'

	s.metadata = {
		'bug_tracker_uri' => 'https://github.com/AlexWayfer/flame-cli/issues',
		'documentation_uri' =>
			"http://www.rubydoc.info/gems/flame-cli/#{s.version}",
		'homepage_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'source_code_uri' => 'https://github.com/AlexWayfer/flame-cli',
		'wiki_uri' => 'https://github.com/AlexWayfer/flame-cli/wiki'
	}

	s.add_runtime_dependency 'clamp', '~> 1.3'
	s.add_runtime_dependency 'gorilla_patch', '~> 3.0'

	s.add_development_dependency 'codecov', '~> 0'
	s.add_development_dependency 'pry', '~> 0'
	s.add_development_dependency 'pry-byebug', '~> 3.5'
	s.add_development_dependency 'puma', '~> 3.12'
	s.add_development_dependency 'rake', '~> 12'
	s.add_development_dependency 'rspec', '~> 3.7'
	s.add_development_dependency 'rubocop', '~> 0.65.0'
	s.add_development_dependency 'simplecov', '~> 0'

	s.files = Dir['{lib,template}/**/{*,.*}']
	s.executables = ['flame']
end
