# == Synopsis 
#   Gift – Git and FTP, the easy way
#   Gift provides a simple interface for pushing your site to a server that does not support git, via FTP.
#
# == Examples
#   Start my initialising your FTP settings
#     $ gift wrap ftp://username:password@127.0.0.1:21
#
#   When you're ready to deploy, use:
#     $ gift deliver
#
# == Usage 
#   $ gift wrap [server-name] ftp://username:password@127.0.0.1:21
#   $ gift deliver [options]
#
#   For help use: gift -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#
# == Author
#   Nicholas Bruning
#
# == Copyright
#   Copyright (c) 2010 Nicholas Bruning. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'

module Gift
  class Cli
    
    attr_reader :options
    
    def initialize(argv, stdin)
      @arguments = arguments
      @stdin = stdin

      # Set defaults
      @options = OpenStruct.new
      @options.verbose = false
      @options.quiet = false
    end
    
    def run
      if parsed_options? && arguments_valid? 
        puts "Start at #{DateTime.now}\n\n" if @options.verbose
        
        output_options if @options.verbose # [Optional]

        process_arguments            
        process_command

        puts "\nFinished at #{DateTime.now}" if @options.verbose

      else
        output_usage
      end
    end
    
    protected
    
    def wrap
      
    end
    
    def deliver
      
    end
    
    def output_version
      puts "Gift vX.X.X"
    end
    
    def output_help
      output_version
      RDoc::usage() #exits app
    end
    
    def output_usage()
      RDoc::usage('usage') # gets usage from comments above
    end
    
    def parsed_options?
      # Specify options
      opts = OptionParser.new 
      opts.on('-v', '--version')    { output_version ; exit 0 }
      opts.on('-h', '--help')       { output_help }
      opts.on('-V', '--verbose')    { @options.verbose = true }  
      opts.on('-q', '--quiet')      { @options.quiet = true }
      # TO DO - add additional options

      opts.parse!(@arguments) rescue return false

      process_options
      true      
    end
    
    def process_options
      @options.verbose = false if @options.quiet
    end
    
    def output_options
      puts "Options:\n"

      @options.marshal_dump.each do |name, val|        
        puts "  #{name} = #{val}"
      end
    end
    
    def arguments_valid?
      # TO DO - implement your real logic here
      true if @arguments.length == 1 
    end
    
    def process_arguments
      # TO DO - place in local vars, etc
    end
    
    def process_command
      # TO DO - do whatever this app does

      #process_standard_input # [Optional]
    end
    
    def process_standard_input
      input = @stdin.read      
      # TO DO - process input

      # [Optional]
      # @stdin.each do |line| 
      #  # TO DO - process each line
      #end
    end
    
  end
end