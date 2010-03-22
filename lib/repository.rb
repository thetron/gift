require 'git'

module Gift
  class Repository
    
    def initialize
      @repo = Git.open '.'
      
    end
    
    #returns a hash of Gift::File objects
    def diff(sha1, sha2 = nil)
      unless sha2
        # get initial tree and diff between that and
        
      end
    end
    
  end
end