require "rake/testtask"

task :default => :test

def test_task(name, folder)
  Rake::TestTask.new(name) do |test|
      test.test_files = Dir[ "#{folder}/*_test.rb" ]
      test.verbose = true
  end
end

test_task(:test_unit, "test/unit")
test_task(:test_e2e, "test/end2end")
test_task(:test, "test/*")