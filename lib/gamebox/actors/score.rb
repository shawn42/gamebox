class ScoreView < ActorView
  def draw(target,x_off,y_off,z)
    text = @actor.score.to_s
    text = '0'*(6-text.size)+text

    font = resource_manager.load_font 'Asimov.ttf', 30
    x = @actor.x
    y = @actor.y
    font.draw text, x,y,z#, 1,1,target.convert_color([250,250,250,255])
  end
end

define_behavior :score_keeper do
  requires :backstage, :stage

  setup do
    clear if score.nil?
    # TODO helper for "attached subactor"
    label = stage.create_actor(:label, actor.attributes)
    actor.has_attributes label: label
    actor.when :position_changed do
      actor.label.x = actor.x
      actor.label.y = actor.y
    end
    actor.when :remove_me do
      label.remove
    end
    update_text
  end

  helpers do
    def score
      backstage[:score]
    end

    def clear
      backstage[:score] = 0
    end

    def +(amount)
      backstage[:score] += amount
      update_text
      self
    end

    def -(amount)
      backstage[:score] -= amount
      update_text
      self
    end

    def update_text
      actor.label.text = score
    end
  end
end

define_actor :score do
  has_behavior :score_keeper, layered: 999
end
