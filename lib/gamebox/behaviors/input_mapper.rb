define_behavior :input_mapper do
  requires :input_manager

  setup do
    opts.each do |keys, attr_name|
      actor.has_attribute attr_name, false
      input_manager.while_pressed keys, actor, attr_name
    end
  end
end

