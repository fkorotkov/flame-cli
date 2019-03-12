# frozen_string_literal: true

describe 'FlameCLI::New' do
	describe '--help' do
		subject { `#{FLAME_CLI} new --help` }

		it do
			is_expected.to match_words(
				'Usage:', 'flame new [OPTIONS] SUBCOMMAND [ARG]',
				'Subcommands:', 'application, app',
				'Options:', '-h, --help'
			)
		end
	end
end
