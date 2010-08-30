require 'rubygems'

Gem::Specification.new do |spec|
  spec.name = 'rails3_acts_as_paranoid'
  spec.version = "0.0.1"
  spec.summary = "provide for logical destroy"
  spec.files = Dir['init.rb', 'lib/**/*', 'test/**/*', 'Rakefile', '.yardopts']
  spec.has_rdoc = false
  spec.test_files = Dir['test/*_test.rb']
end
