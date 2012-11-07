module PostSetupHandlers
  class PryRemoteServer
    def self.setup(argv,env,config)
      start_remote_pry if config[:debug] or argv.include?('--debug')
    end

    def self.start_remote_pry
      log "Pry Remote Server started!"

      Thread.abort_on_exception = true

      Thread.new do
        loop do
          begin
            if th = DRb.thread
              th.kill
            end

            binding.remote_pry
            log "remote_pry returned"
          rescue Exception => e
            log "finished remote pry"
          end
        end
      end

    end
  end
end
