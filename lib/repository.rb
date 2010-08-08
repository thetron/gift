require 'git'
require 'git_file'

module Gift
  class Repository
    #returns an array of Gift::File objects
    #this may only need the last_commit sha?
    def self.diff(sha)
      repo = Git.open "."
      files = Hash.new
      first_run = false
      
      unless sha && sha != ""
        first_run = true
        # get initial file tree, set sha2 to initial commit hash
        sha = repo.log.to_a.last.sha
        
        #get blobs from initial commit
        repo.log.to_a.last.gtree.blobs.each do |blob|
          file = Gift::GitFile.new(blob.first, :new)
          files[blob.first] = file
        end
      end
      
      repo.diff(sha, repo.log.to_a.first.sha).each do |file|
        unless file.type == "deleted"
          file.type = "new"
          files[file.path] = Gift::GitFile.new(file.path, file.type)
        else
          files[file.path].delete
        end
      end  
      files
    end    
  end
end