require 'actor'

class MajorRuby < Actor

  has_behavior :animated, :updatable

  attr_accessor :move_left, :move_right, :jump
  def setup
    @speed = 8
    @vy = 0
    @map = @opts[:map]
    input_manager.while_key_pressed :left, self, :move_left
    input_manager.while_key_pressed :right, self, :move_right
    input_manager.while_key_pressed :up, self, :jump
    input_manager.reg KeyPressed, :up do 
      try_to_jump
    end
  end

  def update(time_delta)
    # TODO sucks that I have to call this here to update my behaviors
    super time_delta

    time_delta = 1

    #adjust physics
    if move_right
      (@speed * time_delta).times do
        move 1, 0
      end
      self.action = :move_right unless self.action == :move_right
    elsif move_left
      (@speed * time_delta).times do
        move -1, 0
      end
      self.action = :move_left unless self.action == :move_left
    else
      self.action = :idle
    end
    if @vy < 0
      self.action = :jump unless self.action == :jump
    end

    @vy += 1
    if @vy > 0 
      @vy.times { if would_fit?(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0 
      (-@vy).times { if would_fit?(0, -1) then @y -= 1 else @vy = 0 end }
    end
  end

  def try_to_jump
    unless would_fit?(0, 1) 
#      play_sound :jump
      @vy = -20
    end
  end

  def move(dx,dy)
    if would_fit?(dx,0)
      @x += dx 
    end
    if would_fit?(0,dy)
      @y += dy 
    end
  end

  def would_fit?(x_off, y_off)
    not @map.solid? @x.floor+x_off+25, @y.floor+y_off+5 and
    not @map.solid? @x.floor+x_off+25, @y.floor+y_off+45 and
    not @map.solid? @x.floor+x_off+10, @y.floor+y_off+25 and
      not @map.solid? @x.floor+x_off+40, @y.floor+y_off+25 
  end

  def collect_gems(gems)
    gems.reject! do |pg|
      matched = false
      if (pg.x - @x).abs < 50 and (pg.y - @y).abs < 50
        matched = true
        play_sound :pretty
        pg.remove_self
      end
      matched
    end
  end
end
