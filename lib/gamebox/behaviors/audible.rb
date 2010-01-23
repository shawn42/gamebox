require 'behavior'

class Audible < Behavior
  
  def setup
    @sound_manager = @actor.stage.sound_manager

    audible_obj = self
    @actor.instance_eval do
      (class << self; self; end).class_eval do
        define_method :play_sound do |*args|
          audible_obj.play_sound *args
        end
        define_method :stop_sound do |*args|
          audible_obj.stop_sound *args
        end
      end
  end


  end

  # Plays a sound via the SoundManager.  See SoundManager for
  # details on how to "define" sounds.
  def play_sound(*args)
    @sound_manager.play_sound *args
  end

  # Stops a sound via the SoundManager.
  def stop_sound(*args)
    @sound_manager.stop_sound *args
  end

end
