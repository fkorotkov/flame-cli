# frozen_string_literal: true

FLAME_CLI = File.join(__dir__, '../bin/flame').freeze

def transform_words_into_regexp(*words)
	words.map { |word| "(?=.*#{Regexp.escape(word)})" }.join
end

RSpec::Matchers.define :match_words do |*words|
	regexp = transform_words_into_regexp(*words)

	match do |actual|
		actual.match(/#{regexp}/m)
	end

	diffable
end
