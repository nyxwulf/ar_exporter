require 'rubygems'
require 'delimited_file'
# require 'ar_exporter'
require File.join(File.dirname(__FILE__), '../lib/ar_exporter')

parser = DelimitedFile.new('/tmp/users.txt', :mode => :write)

@options = {
  :parser => parser,
  :table_name => 'users',
  :col_mappings => {'id' => 'user_id'}
}

@connection_options = {
  :database => 'dc_dev',
  :adapter  => 'mysql',
  :username => 'root',
  :password => '',
  :host     => 'localhost'
}

@ae = ARExporter.new(@options, @connection_options)
puts @ae.file_name
@ae.export_data