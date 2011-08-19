

class MajorRuby < Actor

  has_behavior :audible, :animated, :updatable, :layered => {:layer => 10}
  attr_accessor :move_left, :move_right, :jump
  def x
    @x
  end
  def x=(px)
    @x = px
  end
  def y
    @y
  end
  def y=(py)
    @y = py
  end

  def setup
    @speed = 8
    @vy = 0
    @map = @opts[:map]
    input_manager.while_key_pressed KbLeft, self, :move_left
    input_manager.while_key_pressed KbRight, self, :move_right
    input_manager.reg :keyboard_down, KbUp do 
      try_to_jump
    end
  end

  def update(time_delta)
    # TODO sucks that I have to call this here to update my behaviors
    super 

    time_delta = (time_delta/25.0).floor

    if move_right
      (@speed * time_delta).times do
        move(1, 0)
      end
      self.action = :move_right unless self.action == :move_right
    elsif move_left
      (@speed * time_delta).times do
        move(-1, 0)
      end
      self.action = :move_left unless self.action == :move_left
    else
      self.action = :idle
    end
    if @vy < 0
      self.action = :jump unless self.action == :jump
    end

    time_delta.times { apply_gravity }

  end

  def apply_gravity
    @vy += 1
    if @vy < 0 
      (-@vy).times { if would_fit?(0, -1) then self.y -= 1 else @vy = 0 end }
    end
    if @vy > 0 
      (@vy).times do 
        if would_fit?(0, 1) 
          if (move_left and !would_fit?(-1,0))
            self.action = :slide_left
            fall_rate = 0.2
          elsif (move_right and !would_fit?(1,0)) 
            self.action = :slide_right
            fall_rate = 0.2            
          else
            fall_rate = 1
          end
          self.y += fall_rate
        else 
          @vy = 0 
        end 
      end
    end
  end

  def try_to_jump
    if !would_fit?(0, 1) || (move_left and !would_fit?(-1,0)) || 
      (move_right and !would_fit?(1,0)) 
#      play_sound :jump
      @vy = -12
    end
  end

  def move(dx,dy)
    if would_fit?(dx,0)
      self.x += dx 
    end
    if would_fit?(0,dy)
      self.y += dy 
    end
  end

  def would_fit?(x_off, y_off)
    not @map.solid? self.x.floor+x_off+5, self.y.floor+y_off+2 and
    not @map.solid? self.x.floor+x_off+31, self.y.floor+y_off+2 and
    not @map.solid? self.x.floor+x_off+5, self.y.floor+y_off+34 and
      not @map.solid? self.x.floor+x_off+31, self.y.floor+y_off+34 
  end

  def collect_gems(gems)
    collected = []
    gems.each do |pg|
      matched = false
      if (pg.x+18 - self.x).abs < 36 and (pg.y+18 - self.y).abs < 36
        matched = true
        play_sound :pretty
        pg.remove_self
        collected << pg
      end
      matched
    end
    collected
  end
end
