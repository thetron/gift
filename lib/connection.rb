require 'net/ftp'
require 'ptools'
require 'progress_bar'
require 'constants'

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
      @ftp.passive = true
      @ftp.resume = true
      @ftp.chdir(self.path)
      
      #check and setup by default?
      self.setup unless valid?
    end
    
    # creates remote .gift folders
    def setup
      pbar = ProgressBar.new("setup recipient", 4) if self.verbose
      
      @ftp.mkdir(Gift::GIFT_DIR) unless @ftp.nlst.include?(Gift::GIFT_DIR)
      pbar.inc if self.verbose
      
      @ftp.chdir('.gift')
      pbar.inc
      
      @ftp.mkdir('deliveries') unless @ftp.nlst.include?('deliveries') 
      pbar.inc 
      
      pbar.finish if self.verbose
    end
    
    #check for remote folders
    def valid?
      #return @ftp.can_connect? Rescue Excepttion => e
      return false
    end
    
    # deletes remote file from server
    def delete(file)
      pbar = ProgressBar.new("Deleting #{file.filename}", 1) if self.verbose
      @ftp.delete(file)
      pbar.finish
    end
    
    # uploads a file to remote server
    def upload(file)
      pbar = ProgressBar.new("Uploading #{file.filename}", 1) if self.verbose
      
      create_directories(file.a_dir)
      
      if file.binary?(filename)
        @connection.putbinaryfile(filename)
      else 
        @connection.puttextfile(filename)
      end
      
      pbar.finish if self.verbose
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
    
    def last_commit
      sha = ""
      @ftp.chdir(File.join(Gift::GIFT_DIR, Gift::DELIVERIES_DIR))
      last_delivery_report = @ftp.nlst.last
      if @ftp.nlst.length > 2
        @ftp.gettextfile(last_delivery_report) do |f|
          sha = f
        end
        File.delete(last_delivery_report)
      end
      sha
    end
  end
end