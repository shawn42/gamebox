#require 'publisher'
class ModeManager

#  constructor :intro_mode
  def initialize
    @modes = {}
  end

  def add_mode(mode_sym, mode_instance)
    @modes[mode_sym] = mode_instance
    for e in mode_instance.events
      mode_instance.when e do
        #blah
        p e
      end
    end

    @mode = mode_sym unless @mode
    mode_instance
  end

  def change_mode_to(mode, *args)
    @modes[@mode].stop unless @modes[@mode].nil?
    @mode = mode
    @modes[@mode].start *args
  end

  def current_mode
    @modes[@mode]
  end

  def update(time)
    @modes[@mode].update time unless @modes[@mode].nil?
  end

  def draw(target)
    @modes[@mode].draw target unless @modes[@mode].nil?
  end
end
