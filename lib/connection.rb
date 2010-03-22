require 'net/ftp'
require 'ptools'
require 'progress_bar'

module Gift
  class Connection
    attr_accessor :username, :password, :host, :port, :path, :verbose
    
    # constructor, creates ftp object
    def init(host, path, username = "", password = "", port = 21, verbose = true)
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
      if File.binary?(filename)
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
    
  end
end