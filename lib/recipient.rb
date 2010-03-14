module Gift
  class Recipient
    attr_accessor :id, :username, :password, :host, :port, :path
    
    def create_remote_folder
      
    end
    
    def connection_valid?
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
    end
    
    def connect
      @connection = Net::FTP.new(uri.host, username, password)
      @connection.chdir(uri.path)
    end
    
    def disconnect
      @connection.close
    end
  end
end