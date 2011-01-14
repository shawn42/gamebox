GAMEBOX_PATH = File.join(File.dirname(__FILE__),"gamebox/")
require 'diy'
require 'constructor'
require 'kvo'
require 'gosu'
include Gosu

require 'require_all'
require_all Dir.glob("#{GAMEBOX_PATH}/**/*.rb").reject { |f| f.match("template_app") || f.match("spec") || f.match("gamebox_application.rb")}
