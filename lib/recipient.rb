require 'ftools'
require 'yaml'
require 'git'
require 'constants'
require 'connection'

module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    def initialize(host, path = "/", username = "", password = "", port = 21)
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
      last_commit = @connection.last_commit
      files = @repo.diff(last_commit)
      files.each do |file|
        #@connection.call file.action, file.path #or whatever the syntax might be
      end
      puts "Everything up to date!" if files.length == 0
      self.save_state(last_commit)
    end
    
    # Sets up gift directories on remote server
    def setup_remote_dirs
      @connection.create_directories([Gift::GIFT_DIR, File.join(Gift::GIFT_DIR, DELIVERIES_DIR)])
    end
    
    # dump object to YAML file
    def save
      self.id = "ftp-default" unless self.id
      
      yaml = YAML::dump(self)
      fp = open('.gift/recipients.yml', 'w')
      fp.write(yaml)
      fp.close
    end
    
    # checks if a connection exists and is valid
    def valid_connection?
      @connection && @connection.valid?
    end
    
    protected
    def save_state(sha)
      file_name = File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR, id, Time.now.to_id.to_s)
      fp = File.open(file_name, "w")
      fp.puts sha
      fp.close
      @connection.upload(File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR, file_name))
    end
    
    def self.find_by_id(id)
      #incomplete
      YAML::load_file(File.join(Gift::GIFT_DIR, Gift::RECIPIENTS_FILENAME))
    end
    
    def self.all
      YAML::load_file(File.join(Gift::GIFT_DIR, Gift::RECIPIENTS_FILENAME)).to_a
    end
    
    def setup_gift_dirs
      File.makedirs Gift::GIFT_DIR unless File.exists?(Gift::GIFT_DIR)
      File.makedirs File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR) unless File.exists?(File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR))
      File.makedirs File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR, self.id)
    end
  end
end