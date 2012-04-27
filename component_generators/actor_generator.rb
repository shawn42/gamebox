# class GameboxGenerator < RubiGen::Base
#   def manifest
#     record do |m|
#       # Root directory and all subdirectories.
#       m.directory ''
#       BASEDIRS.each { |path| m.directory path }
#       binding.pry
#       m.template 'actor.erb', "src/actors/#{name}.rb", 
#       m.template 'actor_spec.erb', "spec/actors/#{name}_spec.rb", 
#     end
#   end
#   BASEDIRS = %w(
#     src/actors
#     spec/actors
#   )
# end
# 
