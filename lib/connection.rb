require 'net/ftp'
require 'ptools'
require 'progress_bar'

module Gift
  class Connection
    attr_accessor :username, :password, :host, :port, :path, :verbose
    connection_methods = { :modified => :upload, :renamned => :rename, :new => :upload, :deleted => :delete }
    
    # constructor, creates ftp object
    def initialize(host, path, username = "", password = "", port = 21, verbose = true)
      self.username = username
      self.password = password
      self.host = host
      self.path = path
      self.verbose = verbose
      
      @ftp = Net::FTP.new(self.host, self.username, self.password)
      @ftp.chdir(self.path)
      
      #check and setup by default?
      self.setup unless valid?
    end
    
    # creates remote .gift folders
    def setup
      pbar = ProgressBar.new("setup recipient", 5) if self.verbose
      
      pbar.inc if self.verbose
      
      pbar.finish if self.verbose
    end
    
    #check for remote folders
    def valid?
      return false
    end
    
    # deletes remote file from server
    def delete(file)
      @ftp.delete(file)
    end
    
    # uploads a file to remote server
    def upload(file)
      create_directories(file.a_dir)
      
      if file.binary?(filename)
        @connection.putbinaryfile(filename)
      else 
        @connection.puttextfile(filename)
      end
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
    
    # checks if directory exists on remote and (recursively) creates as necessary
    def create_directories(dirs)
      
    end
    
    def self.file_method(action)
      connection_methods[action]
    end
  end
end