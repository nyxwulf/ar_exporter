require 'rubygems'
require 'delimited_file'
require File.join(File.dirname(__FILE__), '../lib/ar_exporter')

describe ARExporter do
  before(:each) do
    @options = {
      :file_name => '/tmp/people_data.txt',
      :table_name => 'people_data'
    }

    @connection_options = {
      :database => 'ar_exporter_test',
      :adapter  => 'mysql',
      :username => 'root',
      :password => '',
      :host     => 'localhost'
    }
    
    @ae = ARExporter.new(@options, @connection_options)
  end
  
  it "should infer the filename from the specified table_name" do
    options = {
      :table_name => 'people_data'
    }
    
    ae = ARExporter.new(options, @connection_options)
    ae.file_name.should === File.join(Dir.pwd, 'people_data.txt')
  end
  
  it "should export data from the ActiveRecord model into a delimited text file" do
    @ae.export_data
    fh = open( '/tmp/people_data.txt', 'r')
    content = fh.read()

    content.should == "age<COL>first<COL>last<EOL>33<COL>doug<COL>tolton<EOL>31<COL>torrey<COL>tolton<EOL><COL>lisa<COL>tolton<EOL>"
  end
  
  it "should handle column renames" do
    options = {:col_mappings => {'first' => 'first_name', 'last' => 'last_name'}}.merge(@options)
    ae = ARExporter.new(options, @connection_options)
    ae.export_data
    
    fh = open('/tmp/people_data.txt')
    content = fh.read
    
    content.should == "age<COL>first_name<COL>last_name<EOL>33<COL>doug<COL>tolton<EOL>31<COL>torrey<COL>tolton<EOL><COL>lisa<COL>tolton<EOL>"
  end
end