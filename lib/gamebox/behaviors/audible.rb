

class Audible < Behavior
  
  def setup
    @sound_manager = @actor.sound_manager

    audible_obj = self
    relegates :play_sound, :stop_sound
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
