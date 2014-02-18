define_behavior :score_keeper do
  requires :backstage, :stage

  setup do
    # TODO helper for "attached subactor"
    label = stage.create_actor(:label, actor.attributes)
    actor.has_attributes label: label, score: 0
    actor.when :position_changed do
      actor.label.x = actor.x
      actor.label.y = actor.y
    end
    actor.when(:remove_me) { label.remove }
    actor.when(:score_changed) { update_text }
    update_text
  end

  helpers do
    def update_text
      actor.label.text = actor.score
    end
  end
end

define_actor :score do
  has_behavior :score_keeper, layered: 999
end
