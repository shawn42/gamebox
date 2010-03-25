# This is the generator for gamebox
require 'inflector'
$: << File.join(File.dirname(__FILE__),'generators')

unless "".respond_to? :end_with?
  class String
    def end_with?(ending)
      self[size-ending.size..-1] == ending
    end
  end
end

def print_usage
  puts "generate what *opts"
  puts "TODO list all generators here"
end
# TODO pull these out into generators/ dir for listing

if ARGV.size < 1
  print_usage 
  exit 0
end

# TODO load generator file based on ARGV[0]
generator_klass_name = 
  Inflector.camelize ARGV[0].downcase+"_generator"

require Inflector.underscore(generator_klass_name)

generator_klass = Object.const_get generator_klass_name
generator_klass.new.generate(ARGV[1..-1])

