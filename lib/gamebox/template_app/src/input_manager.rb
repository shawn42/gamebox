class InputManager
  extend Publisher
  can_fire :key_up, :event_received
  
  def initialize()
    @queue = EventQueue.new
    @queue.ignore = [
      ActiveEvent,
      JoyAxisEvent,
      JoyBallEvent,
      JoyDownEvent,
      JoyHatEvent,
      JoyUpEvent,
      ResizeEvent
    ]
    
    @clock = Clock.new do |c|
      c.target_framerate = 40
    end
  end

  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        @queue.each do |event|
          fire :event_received, event
          case event
          when KeyDownEvent
            case event.key
            when K_F
              puts "Framerate:#{@clock.framerate}"
            when K_ESCAPE
              throw :rubygame_quit
            end
          when KeyUpEvent
            fire :key_up, event
          when QuitEvent
            throw :rubygame_quit
          end
        end

        game.update @clock.tick
      end
    end
  end
end
