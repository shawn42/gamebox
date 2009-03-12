class SoundManager

  constructor :resource_manager, :config_manager
  def setup
    # Not in the pygame version - for Rubygame, we need to 
    # explicitly open the audio device.
    # Args are:
    #   Frequency - Sampling frequency in samples per second (Hz).
    #               22050 is recommended for most games; 44100 is
    #               CD audio rate. The larger the value, the more
    #               processing required.
    #   Format - Output sample format.  This is one of the
    #            AUDIO_* constants in Rubygame::Mixer
    #   Channels -output sound channels. Use 2 for stereo,
    #             1 for mono. (this option does not affect number
    #             of mixing channels) 
    #   Samplesize - Bytes per output sample. Specifically, this
    #                determines the size of the buffer that the
    #                sounds will be mixed in.
#    Rubygame::Mixer::open_audio( 22050, Rubygame::Mixer::AUDIO_U8, 2, 1024 )
    Rubygame::Mixer::open_audio( 22050, nil, 2, 1024 )

    puts 'Warning, sound disabled' unless
      (@enabled = (Rubygame::VERSIONS[:sdl_mixer] != nil))
    @enabled = (@enabled and (@config_manager.settings[:sound].nil? or @config_manager.settings[:sound] == true))

    if @enabled
      @music = {}
      files = Dir.glob "#{MUSIC_PATH}**"
      for f in files
        name = File.basename(f)
        sym = name.gsub(" ","_").split(".")[0..-2].join(".").to_sym
        @music[sym] = @resource_manager.load_music(f)
      end if files

      @sounds = {}
      files = Dir.glob "#{SOUND_PATH}**"
      for f in files
        name = File.basename(f)
        sym = name.gsub(" ","_").split(".")[0..-2].join(".").to_sym
        @sounds[sym] = @resource_manager.load_music(f)
      end if files
    end
  end

  def enabled?
    @enabled
  end

  def play_sound(what)
    if @enabled
      @sound_thread = Thread.new do
        @sounds[what].play if @sounds[what]
      end
    end
  end

  def play(what)
    if @enabled
      @sound_thread = Thread.new do
        @music[what].play :repeats => -1 if @music[what]
      end
    end
  end

  def stop(what)
    if @enabled
      @music[what].stop if @music[what]
    end
  end

end
