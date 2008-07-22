# dataloader.gemspec
require 'rubygems'
spec = Gem::Specification.new do |spec|
  spec.name = 'ar_exporter'
  spec.summary = 'Simple data exporter for ActiveRecord using DelimitedFile parser'
  spec.description = %{A fast simple data exporter designed to work with ActiveRecord using the 
      DelimitedFile parser gem.
  }
  spec.author = 'Doug Tolton'
  spec.email = 'ar_exporter.closure@recursor.net'
  spec.test_files = Dir['test/*']
  spec.has_rdoc = true
  spec.files = Dir['lib/*.rb'] + spec.test_files
  spec.version = '0.1.0'
  spec.add_dependency('delimited_file')
  spec.add_dependency('activerecord')
end