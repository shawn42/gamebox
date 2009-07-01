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
desc "Run the game with debug server"
task :debug do |t|
  if Platform.mac?                                               
    sh "rsdl src/app.rb -debug-server"                                          
  else
    sh "ruby src/app.rb -debug-server"                                         
  end
end
