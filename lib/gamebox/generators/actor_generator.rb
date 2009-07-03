
class ActorGenerator
  require 'erb'
  def generate(*args)

    @actor_name = ARGV[1]
    @behaviors = ARGV[2]
    @bind = binding

    build_actor
    build_test_actor

    # load test_actor and replace
  end
  
  def build_actor
    template_file = File.open(File.join(GAMEBOX_PATH,'templates','actor.erb'))
    template_contents = template_file.readlines.join
    actor_template = ERB.new(template_contents)

    result = actor_template.result @bind

    out_file = File.join(APP_ROOT,'src',Inflector.underscore(@actor_name)+".rb")
    raise "File exists [#{out_file}]" if File.exists? out_file
    File.open(out_file,"w+") do |f|
      f.write result
    end
  end

  def build_test_actor
    template_file = File.open(File.join(GAMEBOX_PATH,'templates','test_actor.erb'))
    template_contents = template_file.readlines.join
    actor_template = ERB.new(template_contents)

    result = actor_template.result @bind

    out_file = File.join(APP_ROOT,'test','test_'+Inflector.underscore(@actor_name)+".rb")
    raise "File exists [#{out_file}]" if File.exists? out_file
    File.open(out_file,"w+") do |f|
      f.write result
    end
  end
end
