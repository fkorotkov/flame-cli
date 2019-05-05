# frozen_string_literal: true

require 'pathname'
require 'net/http'

describe 'FlameCLI::New::App' do
	let(:app_name) { 'foo_bar' }

	subject(:execute_command) do
		Bundler.with_clean_env { `#{FLAME_CLI} new app #{app_name}` }
	end

	let(:template_dir)          { File.join(__dir__, '../../template') }
	let(:template_dir_pathname) { Pathname.new(template_dir) }
	let(:template_ext)          { '.erb' }

	after do
		FileUtils.rm_r File.join(__dir__, '../..', app_name)
	end

	describe 'output' do
		it do
			is_expected.to match_words(
				"Creating '#{app_name}' directory...",
				'Copy template directories and files...',
				'Clean directories...',
				'Replace module names in template...',
				'- configs/logger.rb',
				'- configs/sequel.rb',
				'- configs/config.rb',
				'- configs/site.example.yaml',
				'- config.ru',
				'- application.rb',
				'- controllers/_controller.rb',
				'- controllers/site/_controller.rb',
				'- controllers/site/index_controller.rb',
				'- Rakefile',
				'- views/site/index.html.erb',
				'- views/site/layout.html.erb',
				'- rollup.config.js',
				'Grant permissions to files...',
				'Done!'
			)
		end
	end

	describe 'creates root directory with received app name' do
		subject { Dir.exist?(app_name) }

		before { execute_command }

		it { is_expected.to be true }
	end

	describe 'copies template directories and files into app root directory' do
		before { execute_command }

		let(:files) do
			Dir[File.join(template_dir, '**/*')]
				.map do |filename|
					filename_pathname = Pathname.new(filename)
						.relative_path_from(template_dir_pathname)

					next if File.dirname(filename).split(File::SEPARATOR).include? 'views'

					if filename_pathname.extname == template_ext
						filename_pathname = filename_pathname.sub_ext('')
					end

					File.join app_name, filename_pathname
				end
				.compact
		end

		subject { File }

		it { files.each { |file| is_expected.to exist file } }
	end

	describe 'cleans directories' do
		before { execute_command }

		subject { Dir[File.join(app_name, '**/.keep')] }

		it { is_expected.to be_empty }
	end

	describe 'renders app name in files' do
		before { execute_command }

		subject { File.read File.join(app_name, *path_parts) }

		describe 'config.ru' do
			let(:path_parts) { 'config.ru' }

			it do
				is_expected.to match_words(
					'FooBar::APP_DIRS',
					'use Rack::Session::Cookie, ' \
						'FB::Application.config[:session][:cookie]',
					'FB::Application.config[:logs_dir]',
					'FB.const_defined?(:DB)',
					'FB::DB.loggers <<',
					'FB.logger',
					'FB::DB.freeze',
					'# FB::Acc = FB::Account',
					'run FB::Application'
				)
			end
		end

		describe 'application.rb' do
			let(:path_parts) { 'application.rb' }

			it do
				is_expected.to match_words(
					'module FooBar',
					'include FB::Config'
				)
			end
		end

		describe 'controllers/_controller.rb' do
			let(:path_parts) { ['controllers', '_controller.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar',
					'FB.logger'
				)
			end
		end

		describe 'controllers/site/_controller.rb' do
			let(:path_parts) { ['controllers', 'site', '_controller.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar',
					'class Controller < FB::Controller'
				)
			end
		end

		describe 'controllers/site/index_controller.rb' do
			let(:path_parts) { ['controllers', 'site', 'index_controller.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar',
					'class IndexController < FB::Site::Controller'
				)
			end
		end

		describe 'configs/logger.rb' do
			let(:path_parts) { ['configs', 'logger.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end

		describe 'configs/config.rb' do
			let(:path_parts) { ['configs', 'config.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar',
					'::FB = ::FooBar',
					'FB::Application.config[:logger]'
				)
			end
		end

		describe 'configs/sequel.rb' do
			let(:path_parts) { ['configs', 'sequel.rb'] }

			it do
				is_expected.to match_words(
					'module FooBar'
				)
			end
		end
	end

	describe 'generates working app' do
		before do
			ENV['RACK_ENV'] = 'development'

			execute_command

			Dir.chdir app_name

			%w[server session site].each do |config|
				FileUtils.cp "configs/#{config}.example.yaml", "configs/#{config}.yaml"
			end

			## HACK for testing while some server is running
			File.write(
				'configs/server.yaml',
				File.read('configs/server.yaml').sub('port: 3000', "port: #{port}")
			)

			## HACK for testing with local version of Flame
			File.write(
				'Gemfile',
				File.read('Gemfile').sub(
					"github: 'AlexWayfer/flame'", "path: '../../flame'"
				)
			)

			Bundler.with_clean_env do
				system 'bundle install'
			end
		end

		let(:port) { 3456 }

		subject do
			begin
				pid = Bundler.with_clean_env { spawn './server start' }

				number_of_attempts = 0

				begin
					number_of_attempts += 1
					response = Net::HTTP.get URI("http://localhost:#{port}/")
				rescue Errno::ECONNREFUSED => e
					sleep 1
					retry if number_of_attempts < 10
					raise e
				end

				response
			ensure
				Bundler.with_clean_env { `./server stop` }
				Process.wait pid
			end
		end

		after do
			Dir.chdir '..'
		end

		it do
			is_expected.to eq <<~RESPONSE
				<!DOCTYPE html>
				<html>
					<head>
						<meta charset="utf-8" />
						<title>FooBar</title>
					</head>
					<body>
						<h1>Hello, world!</h1>

					</body>
				</html>
			RESPONSE
		end
	end

	describe 'grants `./server` file execution permissions' do
		before do
			execute_command

			Dir.chdir app_name
		end

		after do
			Dir.chdir '..'
		end

		subject { File.stat('server').mode.to_s(8)[3..5] }

		it { is_expected.to eq '744' }
	end
end
