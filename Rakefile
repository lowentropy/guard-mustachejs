require 'rake/testtask'

task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "guard-mustachejs"
    gem.summary = %{Converts mustache templates into a single javascript file.}
    gem.email = "lowentropy@gmail.com"
    gem.homepage = "https://github.com/lowentropy/guard-mustachejs"
    gem.authors = ["Nathan Matthews"]
    gem.add_development_dependency 'rake'
    gem.add_development_dependency 'shoulda'
    gem.add_dependency 'guard'
  end
rescue LoadError
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end
