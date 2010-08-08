require 'net/ftp'
require 'ptools'
require 'progressbar'
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
      connection_methods[action]
    end
    
    # returns the last SHA hash of the last uploaded commit
    def last_commit
      sha = ""
      @ftp.chdir(File.join(self.path, Gift::GIFT_DIR, Gift::DELIVERIES_DIR))
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