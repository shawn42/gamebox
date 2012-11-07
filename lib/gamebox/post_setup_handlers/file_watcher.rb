module PostSetupHandlers

  class FileWatcher

    def self.setup(argv,env,config)
      start_file_watcher if config[:debug] or argv.include?('--debug')
    end

    def self.filepaths
      [ "src/behaviors/", "src/actors" ]
    end

    def self.start_file_watcher
      log "File Watcher is now watching (#{filepaths.join(', ')}) for changes."

      Thread.abort_on_exception = true

      Thread.new do
        require 'listen'
        Listen.to(*filepaths, filter: /\.rb$/) do |modified, added, removed|
          (modified + added).each do |path|
            path[/([^\/]*)\.rb/]
            filename = $1
            case path
            when /behaviors/
              reload_behavior filename
            when /actors/
              load_actor filename
            end
          end
        end
      end
    end

  end

end
