
class ViewGenerator
  require 'erb'
  def generate(*args)

    @actor_view_name = ARGV[1]
    @actor_view_name += "View" unless @actor_view_name.end_with? "View"
    @behaviors = ARGV[2]
    @bind = binding

    build_actor_view
    build_test_actor_view
  end
  
  def build_actor_view
    template_file = File.open(File.join(GAMEBOX_PATH,'templates','actor_view.erb'))
    template_contents = template_file.readlines.join
    actor_view_template = ERB.new(template_contents)

    result = actor_view_template.result @bind

    out_file = File.join(APP_ROOT,'src',Inflector.underscore(@actor_view_name)+".rb")
    raise "File exists [#{out_file}]" if File.exists? out_file
    File.open(out_file,"w+") do |f|
      f.write result
    end
  end

  def build_test_actor_view
    template_file = File.open(File.join(GAMEBOX_PATH,'templates','actor_view_spec.erb'))
    template_contents = template_file.readlines.join
    actor_view_template = ERB.new(template_contents)

    result = actor_view_template.result @bind

    out_file = File.join(APP_ROOT,'spec',Inflector.underscore(@actor_view_name)+"_spec.rb")
    raise "File exists [#{out_file}]" if File.exists? out_file
    File.open(out_file,"w+") do |f|
      f.write result
    end
  end
end
