require 'git'

module Gift
  class Repository
    #returns an array of Gift::File objects
    #this may only need the last_commit sha?
    def self.diff(sha)
      repo = Git.open "."
      files = Array.new
      
      unless sha
        # get initial file tree, set sha2 to initial commit hash
        sha2 = repo.log.to_a.last.sha
        
        #get blobs from initial commit
        repo.log.to_a.last.gtree.blobs.each do |blob|
          file = Gift::File.new(blob.first, :new)
          files.push file
        end
      end
      
      repo.diff(sha, repo.log.to_a.first.sha).each do |file|
        files.push Gift::File.new(file.path, file.type)
      end  
      files
    end    
  end
end