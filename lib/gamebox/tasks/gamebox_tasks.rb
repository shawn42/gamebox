require 'gamebox/platform'

task :default => :run
desc "Run the game"
task :run do |t|
  if Platform.mac?                                               
    sh "rsdl src/app.rb"                                          
  else
    sh "ruby src/app.rb"                                         
  end
end 
