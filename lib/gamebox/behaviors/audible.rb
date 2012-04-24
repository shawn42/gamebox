

Behavior.define :audible do
  
  requires :sound_manager
  setup do
    reacts_with :play_sound, :stop_sound
  end

  helpers do
    # Plays a sound via the SoundManager.  See SoundManager for
    # details on how to "define" sounds.
    def play_sound(*args)
      sound_manager.play_sound *args
    end

    # Stops a sound via the SoundManager.
    def stop_sound(*args)
      sound_manager.stop_sound *args
    end
  end

end
