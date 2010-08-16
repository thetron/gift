require 'git'
require 'git_file'

module Gift
  class Repository
    # returns the last_commit on the repo
    def self.last_commit_hash
      repo = Git.open "."
      return repo.log.first.sha
    end
    
    # returns hash of Gift::GitFile objects
    def self.diff(sha)
      repo = Git.open "."
      files = Hash.new
      first_run = false
      
      # no hash given, return the current tree
      unless sha && sha != ""
        repo.log.first.gtree.full_tree.each do |blob_string|
          filename = blob_string.split(" ").last
          file = Gift::GitFile.new(filename, :new)
          files[filename] = file
        end
      else
        repo.diff(sha, repo.log.to_a.first.sha).each do |file|
          unless file.type == "deleted"
            file.type = "new"
            files[file.path] = Gift::GitFile.new(file.path, file.type)
          else
            files[file.path].delete
          end
        end 
      end
      files
    end    
  end
end