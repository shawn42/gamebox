GAMEBOX_PATH = File.join(File.dirname(__FILE__),"gamebox/")
require 'chipmunk'
require 'diy'
require 'constructor'
require 'kvo'
require 'gosu'
include Gosu
require 'pry'
require 'pry-remote'


# TODO move this to some logging class
def log(output, level = :debug)
  t = Time.now
  puts "[#{t.min}:#{t.sec}:#{t.usec}] [#{level}] #{output}"
end

require 'require_all'
require_all Dir.glob("#{GAMEBOX_PATH}/**/*.rb").reject { |f| f.match("template_app") || f.match("spec") || f.match("gamebox_application.rb")}
