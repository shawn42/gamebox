ADDITIONAL_LOAD_PATHS = []
ADDITIONAL_LOAD_PATHS.concat %w(
  src 
  lib
  config 
).map { |dir| File.dirname(__FILE__) + "/../" + dir }.select { |dir| File.directory?(dir) }

ADDITIONAL_LOAD_PATHS.each do |path|
	$:.push path
end

APP_ROOT = File.dirname(__FILE__) + "/../"
DATA_PATH =  APP_ROOT + "data/"
CONFIG_PATH = APP_ROOT + "config/"

