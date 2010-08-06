require 'ftools'
require 'yaml'
require 'git'

module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    def create

    end

    def load(id)
      #find connction by identifier from .gift
    end
    
    def update_remote
      last_commit = @connection.last_commit
      files = @repo.diff(last_commit)
      files.each do |file|
        #@connection.call file.method, file.path #or whatever the syntax might be
      end
      puts "Everything up to date!" if files.length == 0
      self.save_state(last_commit)
    end
    
    def save
      unless self.id
        self.id = "ftp-1"
      end
      
      yaml = YAML::dump(self)
      fp = open('.gift/recipients.yml', 'w')
      fp.write(yaml)
      fp.close
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