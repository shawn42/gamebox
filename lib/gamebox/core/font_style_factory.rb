class FontStyleFactory
  construct_with :this_object_context

  def build(name, size, color, x_scale=1, y_scale=1)
    this_object_context.in_subcontext do |style_context|
      style_context["font_style"].tap do |style|
        style.configure name, size, color, x_scale, y_scale
      end
    end
  end
end
