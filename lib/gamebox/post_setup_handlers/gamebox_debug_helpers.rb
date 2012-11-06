
module PostSetupHandlers

  class GameboxAppAddDebugHelpers
    def self.setup(argv,env,config)
      if config[:debug] or ARGV.include?("--debug")
        log "GameboxApp now includes DEBUG Helpers"
        GameboxApp.send :include, DebugHelpers
      end
    end

  end

  GameboxApp.register_post_setup_handler GameboxAppAddDebugHelpers
end