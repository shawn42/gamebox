class WrappedScreen
  constructor :config_manager
  attr_accessor :screen
  def setup
    w,h = @config_manager[:screen_resolution]
    flags = []
    flags << HWSURFACE
    flags << DOUBLEBUF
    flags << FULLSCREEN if @config_manager[:fullscreen]
    flags << OPENGL if @config_manager[:opengl]
    @screen = Screen.set_mode [w,h], 0, flags
  end
  def method_missing(name,*args)
    @screen.send name, *args
  end
end
