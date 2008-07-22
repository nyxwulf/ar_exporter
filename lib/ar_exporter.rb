# =ARExporter is a simple ActiveRecord exporter using the delimited_file parser
# The motivation is to create a simple way to export ActiveRecord models into delimited text files.

require 'rubygems'
require 'delimited_file'
require 'activerecord'

# Exporter class used to set the table name and export the data
class Exporter < ActiveRecord::Base; end

class ARExporter
  # Options are:
  # * table_name - what table you want to export data from.
  # * file_name - path to the file you want to export data to, defaults to the current path with the file named after the table with a .txt extension
  # * parser - a PipeDelimited parser to parse the data, defaults to nil.  If nil, a new parser will be constructed using the defaults
  # * progress - defaults to report every 250 rows loaded, if set to 0 progress results will be omitted.
  # * find_options - valid options for an ActiveRecord find(:all) call.  If nil will default to simply find(:all)
  # 
  # Connection options are valid options for an ActiveRecord connection for example:
  # * adapter - ActiveRecord adapter type, no default
  # * host    - The host you are connecting to, no default
  # * database - The database you want to work with, no default
  def initialize(options = {}, connection_parameters = {})
    @connection_parameters = connection_parameters
    merge_options options
    validate_options(@options)
    establish_connection
    set_date_formats
    @rows_exported = 0
    @rows_error = 0
  end
  
  
  attr_accessor :options
  attr_reader :rows_exported, :rows_error
  
  def validate_options(options)
    if options[:table_name].nil? || options[:table_name] == ""
      raise ArgumentError, ":Table Name cannot be nil"
    end
  end
  
  # Merges supplied options with the default options
  def merge_options(options)
    @options = {
      :file_name => nil,
      :progress   =>  250,
      :find_options => {}
    }.merge(options)
  end

  # Establish a connection to the database using the supplied configuration
  # :adapter  => 'mysql',
  # :host     => 'localhost',
  # :database => 'my_database'
  def establish_connection
    ActiveRecord::Base.establish_connection(@connection_parameters)
  end

  def set_date_formats
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:default => '%m/%d/%Y %I:%M%p')
    ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:default => '%m/%d/%Y')
  end
  
  # If no file name is supplied, use the name of the table for the file name
  def file_name
    if @options[:file_name].nil?
      if @options[:parser].nil?
        tn = @options[:table_name]
        @options[:file_name] = File.join(Dir.pwd, tn + '.txt')
      else
        @options[:file_name] = @options[:parser].file_name
      end
    end
    @options[:file_name]
  end
  
  # Export the data into the file.
  # This method makes use of the PipeDelimited parser with the default options
  # if you need to specify something other than the default options pass a populated
  # PipeDelimited object in the options has as :parser.
  def export_data
    set_base_table(@options[:table_name])
    progress = @options[:progress]

    pd = nil
    if @options[:parser] == nil
      df = DelimitedFile.new(file_name, :mode => :write)
    else
      df = @options[:parser]
    end

    count = Exporter.count(:all, @options[:find_options])

    return false if count == 0

    record = Exporter.find(:first, @options[:find_options])
    df.write_header(col_map(record.attributes)) 

    page_size = 1_000
    page = 0
    
    while ((page * page_size <= count))

      records = Exporter.find(:all, @options[:find_options].merge(:limit => page_size, :offset => (page * page_size)))
    
      records.each_with_index do |row, index|
        begin
          df.write_line(col_map(row.attributes))
          @rows_exported += 1
        
          if progress > 0 && (@rows_exported % progress) == 0
            print "."
            puts if progress > 0 && (@rows_exported % 20_000) == 0
            $stdout.flush
          end
        
        rescue Exception => ex
          @rows_error += 1
          puts "Error saving line #{index}"
          p "Error Info: #{ex}"
          row.attributes.keys.each do |key|
            puts "row[#{key}] = #{row[key]}"
          end
          puts       
        end # begin / rescue block
      end # records.each_with_index
      
      page += 1
    end # while
    
    df.close_file
    puts
  end
    
  def col_map(row)
    return row if @options[:col_mappings].nil?
    
    output = row.dup
    
    @options[:col_mappings].keys.each do |key|
      output[@options[:col_mappings][key]] = output.delete(key)
    end
    
    output
  end
  
  def database_rows
    Loader.count(:all)
  end
  
  # dynamically bind Loader to the table_name we are loading data for.
  def set_base_table(table_name)
    mystr = <<-EOL
    class Exporter < ActiveRecord::Base
      set_table_name '#{table_name}'
    end
    EOL
    eval(mystr)
    
    # Avoid problems with STI and exporting data
    Exporter.inheritance_column = nil
  end
 
  
end