APP_ROOT = "#{File.join(File.dirname(__FILE__),"..")}/"
ADDITIONAL_LOAD_PATHS = []
ADDITIONAL_LOAD_PATHS.concat %w(
  src
  lib
  config 
  ../../lib
).map { |dir| File.join(APP_ROOT,dir) }


CONFIG_PATH = APP_ROOT + "config/"
DATA_PATH =  APP_ROOT + "data/"
SOUND_PATH =  APP_ROOT + "data/sounds/"
MUSIC_PATH =  APP_ROOT + "data/music/"
GFX_PATH =  APP_ROOT + "data/graphics/"
FONTS_PATH =  APP_ROOT + "data/fonts/"

require 'gamebox'

GAMEBOX_DATA_PATH =  GAMEBOX_PATH + "data/"
GAMEBOX_SOUND_PATH =  GAMEBOX_PATH + "data/sounds/"
GAMEBOX_MUSIC_PATH =  GAMEBOX_PATH + "data/music/"
GAMEBOX_GFX_PATH =  GAMEBOX_PATH + "data/graphics/"
GAMEBOX_FONTS_PATH =  GAMEBOX_PATH + "data/fonts/"

ADDITIONAL_LOAD_PATHS.each do |path|
	$:.unshift path
end

require 'require_all'
require_all Dir.glob("**/*.rb").reject{ |f| f.match("spec") || f.match("src/app.rb") || f.match("environment.rb")}

require "#{GAMEBOX_PATH}gamebox_application"

