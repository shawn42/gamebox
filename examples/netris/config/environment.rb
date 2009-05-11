require 'rubygems'
ADDITIONAL_LOAD_PATHS = []
ADDITIONAL_LOAD_PATHS.concat %w(
  src 
  lib
  config 
  ../../lib
).map { |dir| File.dirname(__FILE__) + "/../" + dir }.select { |dir| File.directory?(dir) }

ADDITIONAL_LOAD_PATHS.each do |path|
	$:.push path
end

APP_ROOT = File.dirname(__FILE__) + "/../"
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

