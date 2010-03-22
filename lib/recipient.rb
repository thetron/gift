require 'ftools'
require 'yaml'
require 'ptools'
require 'git'

module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    
    def create

    end

    def load(id)
      #find connction by identifier from .gift
    end
    
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
      
      if(remote_commit == "")
        remote_commit = repo.log.to_a.last.sha
        puts "Pushing files from initial tree"
        #push blobs on first commit
        repo.log.to_a.last.gtree.blobs.each do |blob|
           upload_file(blob.first) if File.exists?(blob.first)
        end
      end
            
      file_count = 0  
      
      puts("Last remote commit: #{remote_commit} | Current local commit: #{repo.log.to_a.first.sha}")
      
      repo.diff(remote_commit, repo.log.to_a.first.sha).each do |file|
        unless(file.path.split('/').first == ".gift")
          if file.type == "deleted"
            begin
              #size = @connection.size(file.path)
              delete_remote_file(file.path)
            rescue Exception => e
              puts "Delete skipped #{file.path} (file not found)"
            end
          else
            upload_file(file.path)
          end
        end
        file_count += 1
      end
            
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
      last_delivery_report = @connection.nlst.last
      if @connection.nlst.length > 2
        @connection.gettextfile(last_delivery_report) do |f|
          sha = f
        end
        File.delete(last_delivery_report)
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
      puts "Uploading #{filename}"
      connect
      if File.binary?(filename)
        @connection.putbinaryfile(filename)
      else 
        @connection.puttextfile(filename)
      end
      disconnect
    end
    
    def delete_remote_file(filename)
      puts "Deleting #{filename}"
      connect
      @connection.delete(filename)
      disconnect
    end
  end
end