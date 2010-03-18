begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "gift"
    gemspec.summary = "Git and FTP, the easy way."
    gemspec.description = "Gift provides a simple interface for pushing your site to a server that does not support git, via FTP."
    gemspec.email = "nicholas@bruning.com.au"
    gemspec.homepage = "http://github.com/thetron/gift"
    gemspec.authors = ["Nicholas Bruning"]
    gemspec.add_dependency('ptools')
    gemspec.add_dependency('git')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end