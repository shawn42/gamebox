# SoundManager auto loads sounds/music from data/sounds and data/music. It makes them accessible via name.
# The name is a symbol of the filename without extension. This means that foo.wav and foo.ogg in the sound
# directory will generate indeterminent behavior.
class SoundManager
  attr_accessor :sounds, :music

  construct_with :resource_manager, :config_manager
  SUPPORTED_AUDIO_EXTS = %w(wav ogg mp3 au aiff caf)
  
  # checks to see if sdl_mixer is availalbe and preloads the sounds and music directories. 
  def initialize

    puts 'CHANGE TO LOG:Warning, sound disabled' unless
    @enabled = (config_manager.settings[:sound].nil? or config_manager.settings[:sound] == true)

    if @enabled
      @music = {}
      files = Dir.glob "#{MUSIC_PATH}**.{#{SUPPORTED_AUDIO_EXTS.join(',')}}"
      for f in files
        name = File.basename(f)
        begin
          sym = name.gsub(" ","_").split(".")[0..-2].join(".").to_sym
          ext = name.gsub(" ","_").split(".").last
          unless ext == "txt"
            @music[sym] = resource_manager.load_music(f)
          end
        rescue;end
      end if files

      @sounds = {}
      @playing_sounds = {}
      files = Dir.glob "#{SOUND_PATH}**.{#{SUPPORTED_AUDIO_EXTS.join(',')}}"
      for f in files
        name = File.basename(f)
        begin
          sym = name.gsub(" ","_").split(".")[0..-2].join(".").to_sym
          ext = name.gsub(" ","_").split(".").last
          unless ext == "txt"
            @sounds[sym] = resource_manager.load_sound(f)
          end
        rescue;end
      end if files
    end
  end

  def enabled?
    @enabled
  end

  # plays the sound based on the name with the specified volume level.
  # play_sound :foo # play sound at 100% volume
  def play_sound(what, opts={})
    if @enabled && @sounds[what]
      merged_opts = {volume:1, speed:1, looping:false}.merge opts
      @playing_sounds[what] = @sounds[what].play merged_opts[:volume], merged_opts[:speed], merged_opts[:looping]
    end
  end

  # plays the music based on the name with the specified volume level.
  # will loop until SoundManager#stop_music is called.
  # play_music :foo, :volume => 0.8  # play music at 80% volumne
  def play_music(what, opts={})
    if @enabled && @music[what]
      volume = opts.delete :volume
      repeat = opts[:repeat]
      repeat ||= false
      @music[what].volume = volume if volume
      @music[what].play repeat
    end
  end

  # stops the music file that is passed in.
  # stop_music :foo
  def stop_music(what)
    if @enabled
      @music[what].stop if @music[what]
    end
  end
  
  # stops the sound that is passed in.
  # stop_sound :foo
  def stop_sound(what)
    if @enabled
      @playing_sounds[what].stop if @playing_sounds[what]
    end
  end

  # TODO
  # def pause_all_sounds;end

end
