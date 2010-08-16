require 'ptools'

module Gift
  class GitFile
    attr_accessor :path, :action
    
    def initialize(path, action)
      self.path = path
      self.action = action
    end
    
    def filename
      self.path.split('/').last
    end
    
    #return dir as string
    def dir
      self.a_dir.join '/'
    end
    
    #return dir as array
    def a_dir
      self.path.split('/')[0...-1]
    end
    
    #return true if file is binary
    def binary?
      File.binary?(self.path)
    end
  end
end