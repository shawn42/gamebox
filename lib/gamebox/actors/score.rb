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
    reacts_with :subtract, :add
  end

  helpers do
    def score
      backstage[:score]
    end

    def clear
      backstage[:score] = 0
    end

    def add(amount)
      backstage[:score] += amount
      update_text
    end

    def subtract(amount)
      backstage[:score] -= amount
      update_text
    end

    def update_text
      actor.label.text = score
    end
  end
end

define_actor :score do
  has_behavior :score_keeper, layered: 999
end
