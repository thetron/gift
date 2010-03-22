module Gift
  class File
    attr_accessor :path, :action
    
    def initialize(path, action)
      self.path = path
      self.action = action
    end
    
    #return dir as string
    def dir
      self.a_dir.join '/'
    end
    
    #return dir as array
    def a_dir
      path.split('/')[0...-1]
    end
    
    #return true if file is binary
    def binary?
      File.binary?(self.path)
    end
  end
end