# == About 
#   Gift – Git and FTP, the easy way
#   Gift provides a simple interface for pushing your site to a server that does not support git, via FTP.
#
#   This version of Gift currenly only supports the master branch of a git repository.
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

# use this for testing:
# ruby lib/cli.rb wrap ftp://dev+involved.com.au:d8u2gy@involved.com.au:21/gift-test

require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'uri'
require 'net/ftp'
require 'yaml'
require 'lib/recipient'

module Gift
  class Cli
    
    attr_reader :options
    
    def initialize(arguments, stdin)
      @arguments = arguments
      @stdin = stdin

      # Set defaults
      @options = OpenStruct.new
      @options.verbose = false
      @options.quiet = false
    end
    
    def run
      if parsed_options?
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
      puts "Gift wrapping #{@server_address}"
      
      #check a local git repository exists
      @errors = fail(["No local git repository found"]) unless File.exists?(".git")
      
      uri = URI.parse(@options.server_address)
      recipient = Gift::Recipient.new
      
      #recipient.id = @options.server_name
      recipient.id = "ftp-1"
      recipient.username = uri.userinfo.split(":")[0]
      recipient.password = uri.userinfo.split(":")[1]
      recipient.host = uri.host
      recipient.port = uri.port
      recipient.path = uri.path    
      
      begin
        puts "Connected to #{recipient.host}" if recipient.valid_connection?
        
        puts "Initialising remote files in #{recipient.host}/#{recipient.path}"
        recipient.setup_remote_dirs
        puts "Remote setup complete"
        
        puts "Initialising local files"
        recipient.setup_local_dirs
        recipient.save
        puts "Local setup complete"
      rescue Exception => e
        fail(["#{e} #{e.class}"])
      end
      
      #populate or refresh .gift/remotes.yml locally
      
    end
    
    def unwrap
      #remove @server_name from local list
      
    end
        
    def deliver
      recipient = Recipient.find_by_id(nil)
      puts "Delivering gift to '#{recipient.id}'"
      recipient.update_remote
    end
    
    def output_version
      puts "Gift v0.0.1"
    end
    
    def output_help
      output_version
      RDoc::usage() #exits app
    end
    
    def output_usage()
      RDoc::usage('usage') # gets usage from comments above
    end
    
    def fail(errors)
      puts "The following errors occurred:"
      puts "\t" + errors.join("\n\t") + "\t"
      output_usage
      
      exit 0;
    end
    
    def parsed_options?
      # Specify options
      opts = OptionParser.new
      
      opts.on('-h', '--help')       { output_help }
      opts.on('-V', '--verbose')    { @options.verbose = true }  
      opts.on('-q', '--quiet')      { @options.quiet = true }
            
      opts.on('-v', '--version') do |version|
        output_version
        exit 0
      end
        
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
      if @command == :wrap
        @options.server_address != nil
      else
        true
      end
    end
    
    def process_arguments
      @command = (@arguments.shift || 'help').to_sym
      
      if(@command == :wrap)
        @options.server_name = @arguments.shift if @arguments.length > 1
        @options.server_address = @arguments.shift
      elsif( [:unwrap, :delivery].include?(@command) )
        @options.server_name = @arguments.shift
      end
    end
    
    def process_command
      if[:wrap, :unwrap, :deliver].include?(@command) && arguments_valid?
        send(@command)
      else
        output_help
        exit 0
      end
    end
  end
end

app = Gift::Cli.new(ARGV, STDIN)
app.run