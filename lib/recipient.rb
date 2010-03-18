require 'ftools'
require 'yaml'
require 'ptools'
require 'git'

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
      unless @connection.nlst.include?('.gift')
        @connection.mkdir('.gift')
      else
        puts 'Remote gift directory already exists'
      end
      
      @connection.chdir('.gift')
      
      unless @connection.nlst.include?('deliveries')
        @connection.mkdir('deliveries')
      else
        puts 'Remote deliveries directory already exists'
      end
      disconnect
    end
    
    def setup_local_dirs
      File.makedirs '.gift' unless File.exists?('.gift')
      File.makedirs '.gift/deliveries' unless File.exists?('.gift/deliveries')
      File.makedirs ".gift/deliveries/#{self.id}"# unless File.exists?(".gift/deliveries/#{self.id}")
    end
    
    def update_remote
      repo = Git.open('./')
      
      remote_commit = last_remote_commit
      remote_commit = repo.log.to_a.last.sha if remote_commit == ""
            
      file_count = 0  
      
      puts("Last remote commit: #{remote_commit} | Current local commit: #{repo.log.to_a.first.sha}")
      
      connect
      repo.diff(remote_commit, repo.log.to_a.first.sha).each do |file|
        unless(file.path.split('/').first == ".gift")
          if file.type == "deleted"
            begin
              size = @connection.size(file.path)
              puts "Deleting #{file.path} [          ] 0%"
              delete_remote_file(file.path)
            rescue Exception => e
              puts "Delete skipped #{file.path} (file not found)"
            end
          else
            puts "Uploading #{file.path} [          ] 0%"
            upload_file(file.path)
          end
        end
        file_count += 1
      end
      disconnect
      
      if file_count == 0
        puts "Everything up to date!"
      else
        save_commit(repo.log.to_a.first.sha)
      end
    end
    
    def last_remote_commit
      sha = ""
      connect
      @connection.chdir('.gift/deliveries')
      if @connection.nlst.length > 2
        @connection.gettextfile(@connection.nlst.last) do |f|
          sha = f
        end
      end
      disconnect
      
      sha
    end
    
    def save_commit(sha)
      file_name = ".gift/deliveries/#{id}/#{Time.now.to_i.to_s}"
      fp = File.open(file_name, "w")
      fp.puts sha
      fp.close
      
      connect
      @connection.chdir('.gift/deliveries')
      @connection.puttextfile(file_name)
      disconnect
      
      puts "Remote state saved"
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
      @connection = Net::FTP.new(host, username, password)
      @connection.chdir(path)
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
      #this will also have to create any missing dirs (unless they're handled the same as files)
      connect
      if File.binary?(filename)
        @connection.putbinaryfile(filename)
      else 
        @connection.puttextfile(filename)
      end
      disconnect
    end
    
    def delete_remote_file(filename)
      connect
      @connection.delete(filename)
      disconnect
    end
  end
end