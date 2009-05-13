require 'svg_physical_level'
class DemoLevel < SvgPhysicalLevel
  
  # extract all the params from a node that are needed to construct an actor
   def create_actors_from_svg
     float_keys = ["x","y"]
     dynamic_actors ||= {}
     layer = @svg_doc.find_group_by_label("actors")
     
     unless layer.nil?
       # each image in the layer is an actor
       layer.images.each do |actor_def|
          klass = actor_def.game_class.to_sym
          handle = actor_def.game_handle
          new_opts = {}
          actor_def.node.attributes.each do |k,v|
            v = v.to_f if float_keys.include? k
            new_opts[k.to_sym] = v
          end
          
          dynamic_actors[handle.to_sym] = create_actor klass, new_opts if handle
       end
     end
     
     dynamic_actors
   end
  
  def setup
    @sound_manager.play :overworld
      
    @space.gravity = vec2(0,800)
    @space.iterations = 10

    @score = create_actor :score, :x => 10, :y => 10
    create_actor :logo, :x => 10, :y => 660

    dynamic_actors = create_actors_from_svg

    create_actor :svg_actor, :name => :ground, :svg_doc => @svg_doc
    create_actor :svg_actor, :name => :death_zone, :svg_doc => @svg_doc

    @nario = dynamic_actors[:nario]

    # TODO fix the viewport to not suck
#    @viewport.follow @nario, [0,70], [300,400]
    @viewport.follow @nario, [0,0], [0,0]

    @space.add_collision_func(:coin, [:nario,:nario_feet,:nario_hat]) do |c,n|
      coin = @director.find_physical_obj c
      unless coin.dying?
        coin.collect
        @score += 10
        create_actor :coin, :x => (200+rand(400)), :y => 100
      end
    end
    
    @space.add_collision_func(:death_zone, [:nario,:nario_feet,:nario_hat]) do |d,n|
      @nario.die
      fire :restart_level
    end

    @space.add_collision_func(:death_zone, :coin) do |d,c|
      coin = @director.find_physical_obj c
      coin.die
    end


    @space.add_collision_func([:ground,:power_up_block], :nario_feet) do |ground_like_obj,nf|
      @nario.stop_jump
    end
    @space.add_collision_func(:power_up_block, :nario_hat) do |pup,n|
      pup_obj = @director.find_physical_obj pup
      if pup_obj.active?
        @nario.stop_jump
        pup_obj.hit
        @score += 10
      end
    end

    @nario.instance_variable_get('@input_manager').reg KeyDownEvent, K_P do
      p @viewport.debug
      p @nario.debug
    end

  end

  def draw(target,x_off,y_off)
    target.fill [25,25,25,255]
  end
end

