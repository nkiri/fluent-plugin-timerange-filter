require 'bundler/gem_tasks'

require 'rake/testtask'

desc 'Run unit tests'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  # test.pattern = 'test/plugin/*.rb'
  test.test_files = FileList['test/**/test*.rb']
  test.verbose = true
end

task default: :test
