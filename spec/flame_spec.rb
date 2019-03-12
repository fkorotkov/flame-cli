# frozen_string_literal: true

describe 'FlameCLI::Flame' do
	describe '--help' do
		subject { `#{FLAME_CLI} --help` }

		it do
			is_expected.to match_words(
				'Usage:', 'flame [OPTIONS] SUBCOMMAND [ARG]',
				'Subcommands:', 'initialize, init, new',
				'Options:', '-h, --help'
			)
		end
	end
end
