GAMEBOX_PATH = File.join(File.dirname(__FILE__),"gamebox/")
require 'conject'
require 'kvo'
require 'tween'
require 'gosu'
include Gosu

require 'forwardable'

# TODO move this to some logging class
def log(output, level = :debug)
  t = Time.now
  puts "[#{t.min}:#{t.sec}:#{t.usec}] [#{level}] #{output}"
end

begin
  require 'pry'
  require 'pry-remote'
rescue LoadError
end

begin
  require 'chipmunk'
rescue LoadError
end

require "#{GAMEBOX_PATH}/version.rb"
require 'require_all'
directory_load_order = %w(lib core actors behaviors views stagehands)
directory_load_order.each do |dir|
  require_all "#{GAMEBOX_PATH}/#{dir}/**/*.rb"
end
