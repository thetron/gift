require 'ftools'
require 'yaml'
require 'git'
require 'progressbar'
require 'repository'
require 'constants'
require 'connection'
require 'git_file'

module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    def initialize(id, host, path = "/", username = "", password = "", port = 21)
      self.id = id
      self.host = host
      self.username = username
      self.password = password
      self.path = path
      self.port = port
      
      @connection = Connection.new(self.host, self.path, self.username, self.password, self.port, true)
    end

    # opens recipients file and loads specified server
    def load(id)
      #find connction by identifier from .gift
    end
    
    # checks the last commit on the remote server and updates the tree accordingly
    def update_remote
      last_commit = @connection.last_commit(self.id)
      files = Repository.diff(last_commit)
      
      if files.length > 0
        puts "#{files.length} changes since last delivery"
        pbar = ProgressBar.new("Uploading", files.length)
        files.each do |file|
          @connection.send(Gift::Connection.file_method(file.last.action), file.last)
          pbar.inc
        end
        pbar.finish
      
        last_commit = Gift::Repository.last_commit_hash unless last_commit && last_commit != ""
        self.save_state(last_commit)
      else
        puts "Everything up to date!"
      end
      
      @connection.close
    end
    
    # Sets up gift directories on remote server
    def setup_remote_dirs
      @connection.create_directories([Gift::GIFT_DIR, File.join(Gift::GIFT_DIR, DELIVERIES_DIR)])
    end
    
    # Sets up local gift directories
    def setup_local_dirs
      File.makedirs Gift::GIFT_DIR unless File.exists?(Gift::GIFT_DIR)
      File.makedirs File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR) unless File.exists?(File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR))
      File.makedirs File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR, self.id)
    end
    
    # FIXME: should only dump the core settings and not the whole object
    def save
      recipients = Recipient.all
      recipients[self.id] = {:host => self.host, :username => self.username, :password => self.password, :path => self.path, :port => self.port}
      yaml = YAML::dump(recipients)
      fp = open((File.join(Gift::GIFT_DIR, Gift::RECIPIENTS_FILENAME)), 'w')
      fp.write(yaml)
      fp.close
    end
    
    # checks if a connection exists and is valid
    def valid_connection?
      @connection && @connection.valid?
    end
    
    # FIXME: Does not do ID lookup
    # FIXME: Should instantiate a NEW recipient opject from loaded settings
    def self.find_by_id(id)
      options = Recipient.all[id]
      Recipient.new(id, options[:host], options[:path], options[:username], options[:password], options[:port])
    end
    
    def self.all
      if File.exists?(File.join(Gift::GIFT_DIR, Gift::RECIPIENTS_FILENAME))
        return YAML::load_file(File.join(Gift::GIFT_DIR, Gift::RECIPIENTS_FILENAME))
      else
        return Hash.new
      end
    end
    
    protected
    def save_state(sha)
      pbar = ProgressBar.new("Finishing", 1)
      
      file_name = File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR, id, Time.now.to_i.to_s)
      fp = File.open(file_name, "w")
      fp.puts sha
      fp.close
      file = Gift::GitFile.new(file_name, :new)
      @connection.upload(file)
      
      pbar.finish
    end
  end
end