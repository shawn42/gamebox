class StageFactory
  construct_with :this_object_context, :backstage

  def build(stage_name, opts={})
    this_object_context.in_subcontext do |stage_context|
      begin
        stage_context[:stage].tap do |stage|

          stage_definition = Stage.definitions[stage_name]
          raise "#{stage_name} not found in Stage.definitions" if stage_definition.nil?
          # requires
          reqs = stage_definition.required_injections
          if reqs
            reqs.each do |req|
              object = stage_context[req]
              stage.define_singleton_method req do
                components[req] 
              end
              components = stage.send :components
              components[req] = object
            end
          end

          renderer_type = stage_definition.renderer || :renderer
          renderer = stage_context[renderer_type]
          stage_context[:renderer] = renderer
          stage.define_singleton_method :renderer do
            components[:renderer] 
          end
          components = stage.send :components
          components[:renderer] = renderer

          # helpers
          helpers = stage_definition.helpers_block
          if helpers
            helpers_module = Module.new &helpers
            stage.extend helpers_module
          end

          stage.configure(backstage, opts)

          # setup
          stage.define_singleton_method(:curtain_up, &stage_definition.curtain_up_block) if stage_definition.curtain_up_block
          stage.define_singleton_method(:curtain_down, &stage_definition.curtain_down_block) if stage_definition.curtain_down_block
        end

      rescue Exception => e
        raise """
          #{stage_name} not found: 
          #{e.inspect}
          #{e.backtrace[0..6].join("\n")}
        """
      end
    end
  end
end
