# [
# "gamebox",
# "gamebox/actors", 
# "gamebox/ai", 
# "gamebox/behaviors", 
# "gamebox/generators", 
# "gamebox/lib", 
# "gamebox/tasks", 
# "gamebox/views"
# ].each do |path|
#   $: << File.dirname(__FILE__)+"/"+path
# end
# 
GAMEBOX_PATH = File.join(File.dirname(__FILE__),"gamebox/")
# require 'gamebox_application'

require 'require_all'
require_all Dir.glob("#{GAMEBOX_PATH}/**/*.rb").reject { |f| f.match("template_app") || f.match("spec") }
