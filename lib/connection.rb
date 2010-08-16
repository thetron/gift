require 'net/ftp'
require 'ptools'
require 'constants'

module Gift
  class Connection
    attr_accessor :username, :password, :host, :port, :path, :verbose
    @@connection_methods = { :modified => :upload, :renamned => :rename, :new => :upload, :deleted => :delete }
    
    # constructor, creates ftp object
    def initialize(host, path, username = "", password = "", port = 21, verbose = true)
      self.username = username
      self.password = password
      self.host = host
      self.path = path
      self.verbose = false
      
      @ftp = Net::FTP.new(self.host, self.username, self.password)
      @ftp.passive = true
      #@ftp.resume = true
      @ftp.chdir(self.path)
    end
    
    # closes the connection
    def close
      @ftp.close
    end
    
    #check for remote folders
    def valid?
      #return @ftp.can_connect? Rescue Excepttion => e
      return false
    end
    
    # deletes remote file from server
    def delete(file, message = nil)
      message = "FTP Deleting #{file.filename}" if message == nil
      puts message if self.verbose
      
      @ftp.delete(file)
      
      puts "DONE" if self.verbose
    end
    
    # uploads a file to remote server
    def upload(file, message = nil)
      message = "FTP Uploading #{file.filename}" if message == nil
      puts message if self.verbose
      
      create_directories(file.a_dir.join("/"))
      
      if file.binary?
        @ftp.putbinaryfile(file.path)
      else 
        @ftp.puttextfile(file.path)
      end
      
      puts "DONE" if self.verbose
    end
    
    # delete and upload
    def rename(old_file, new_file)
      self.delete(old_file)
      self.upload(new_file)
    end
    
    # alias for rename
    def move(old_file, new_file)
      self.rename(old_file, new_file)
    end
    
    # checks if directory exists on remote and creates as necessary
    def create_directories(dirs)
      dirs = dirs.to_a unless dirs.instance_of? Array
      dirs.each do |dir|
        dir_names = dir.split "/"
        @ftp.chdir self.path
        while current_dir = dir_names.shift
          @ftp.mkdir current_dir unless @ftp.nlst.include? current_dir
          @ftp.chdir(current_dir)
        end
      end
    end
    
    # maps git action to ftp connection method
    def self.file_method(action)
      @@connection_methods[action]
    end
    
    # returns the last SHA hash of the last uploaded commit
    # params
    #   id - the id of the recipient
    def last_commit(id)
      sha = ""
      @ftp.chdir(File.join(self.path, Gift::GIFT_DIR, Gift::DELIVERIES_DIR, id))
      ls = @ftp.nlst
      last_delivery_report = ls.last
      if ls.length > 2
        @ftp.gettextfile(last_delivery_report) do |f|
          sha = f
        end
        File.delete(last_delivery_report)
      end
      sha
    end
  end
end