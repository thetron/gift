require 'ftools'
require 'yaml'

module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    def valid_connection?
      begin
        connect
        disconnect
        true
      rescue Exception => e
        false
      end
    end
    
    def setup_remote_dirs
      connect
      ftp.mkdir('.gift')
      ftp.chdir('.gift')
      ftp.mkdir('deliveries')
      disconnect
    end
    
    def setup_local_dirs
      File.makedirs '.gift'
      File.makedirs'.gift/deliveries'
    end
    
    def update_remote
      remote_commit = last_remote_commit
      
      connect
      repo = Git.open('./')
      repo.diff(remote_commit, repo.log.to_a.first.sha).each do |file|
        if file.type == "deleted"
          "Deleting #{file.path} [          ] 0%"
          delete_remote_file(file.path)
        else
          puts "Uploading #{file.path} [          ] 0%"
          upload_file(file.path)
        end
      end
      disconnect
      
      save_commit(repo.log.to_a.first.sha)
    end
    
    def last_remote_commit
      sha = ""
      connect
      @connection.chdir('.gift/deliveries')
      @connection.gettextfile(@connection.ls.last) do |f|
        sha = f
      end
      disconnect
    end
    
    def save_last_commit(sha)
      file_name = ".gift/deliveries/#{id}/#{Time.now.to_i.to_s}"
      fp = File.open(file_name, "w")
      fp.puts sha
      fp.close
      
      connect
      @connection.chdir('.gift/deliveries')
      @connection.puttextfile(file_name)
      disconnect
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
    
    def connect
      @connection = Net::FTP.new(uri.host, username, password)
      @connection.chdir(uri.path)
    end
    
    def disconnect
      @connection.close
    end
    
    def self.find_by_id(id)
      #search recipients.yml for id
      YAML::load_file('.gift/recipients.yml')
    end
    
    def self.all
      YAML::load_file('.gift/recipients.yml')
    end
    
    protected
    
    def upload_file(filename)
      
    end
    
    def delete_remote_file(filename)
      
    end
  end
end