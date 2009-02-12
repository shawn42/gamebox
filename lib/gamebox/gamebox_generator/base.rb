require File.dirname(__FILE__) + '/options'
require File.dirname(__FILE__) + '/manifest'
require File.dirname(__FILE__) + '/spec'

module Gamebox
  # Blatently take from Rails::Generator
  module Generator
    class GeneratorError < StandardError; end
    class UsageError < GeneratorError; end

    class Base
      include Options

      # Declare default options for the generator.  These options
      # are inherited to subclasses.
      default_options :collision => :ask, :quiet => false

      # A logger instance available everywhere in the generator.
      cattr_accessor :logger

      # Every generator that is dynamically looked up is tagged with a
      # Spec describing where it was found.
      class_inheritable_accessor :spec

      attr_reader :source_root, :destination_root, :args

      def initialize(runtime_args, runtime_options = {})
        @args = runtime_args
        parse!(@args, runtime_options)

        # Derive source and destination paths.
        @source_root = options[:source] || File.join(spec.path, 'templates')
        if options[:destination]
          @destination_root = options[:destination]
        elsif defined? ::GAMEBOX_ROOT
          @destination_root = ::GAMEBOX_ROOT
        end

        # Silence the logger if requested.
        logger.quiet = options[:quiet]

        # Raise usage error if help is requested.
        usage if options[:help]
      end

      # Generators must provide a manifest.  Use the +record+ method to create
      # a new manifest and record your generator's actions.
      def manifest
        raise NotImplementedError, "No manifest for '#{spec.name}' generator."
      end

      # Return the full path from the source root for the given path.
      # Example for source_root = '/source':
      #   source_path('some/path.rb') == '/source/some/path.rb'
      #
      # The given path may include a colon ':' character to indicate that
      # the file belongs to another generator.  This notation allows any
      # generator to borrow files from another.  Example:
      #   source_path('model:fixture.yml') = '/model/source/path/fixture.yml'
      def source_path(relative_source)
        # Check whether we're referring to another generator's file.
        name, path = relative_source.split(':', 2)

        # If not, return the full path to our source file.
        if path.nil?
          File.join(source_root, name)

        # Otherwise, ask our referral for the file.
        else
          # FIXME: this is broken, though almost always true.  Others'
          # source_root are not necessarily the templates dir.
          File.join(self.class.lookup(name).path, 'templates', path)
        end
      end

      # Return the full path from the destination root for the given path.
      # Example for destination_root = '/dest':
      #   destination_path('some/path.rb') == '/dest/some/path.rb'
      def destination_path(relative_destination)
        File.join(destination_root, relative_destination)
      end

      def after_generate
      end

      protected
        # Convenience method for generator subclasses to record a manifest.
        def record
          Gamebox::Generator::Manifest.new(self) { |m| yield m }
        end

        # Override with your own usage banner.
        def banner
          "Usage: #{$0} #{spec.name} [options]"
        end

        # Read USAGE from file in generator base path.
        def usage_message
          File.read(File.join(spec.path, 'USAGE')) rescue ''
        end
    end


    class NamedBase < Base
      attr_reader   :name, :class_name, :singular_name, :plural_name, :table_name
      attr_reader   :class_path, :file_path, :class_nesting, :class_nesting_depth
      alias_method  :file_name,  :singular_name
      alias_method  :actions, :args

      def initialize(runtime_args, runtime_options = {})
        super

        # Name argument is required.
        usage if runtime_args.empty?

        @args = runtime_args.dup
        base_name = @args.shift
#        assign_names!(base_name)
      end

      protected
        # Override with your own usage banner.
        def banner
          "Usage: #{$0} #{spec.name} #{spec.name.camelize}Name [options]"
        end
    

      private
#        def assign_names!(name)
#          @name = name
#          base_name, @class_path, @file_path, @class_nesting, @class_nesting_depth = extract_modules(@name)
#          @class_name_without_nesting, @singular_name, @plural_name = inflect_names(base_name)
#          @table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? plural_name : singular_name
#          @table_name.gsub! '/', '_'
#          if @class_nesting.empty?
#            @class_name = @class_name_without_nesting
#          else
#            @table_name = @class_nesting.underscore << "_" << @table_name
#            @class_name = "#{@class_nesting}::#{@class_name_without_nesting}"
#          end
#        end
#
        # Extract modules from filesystem-style or ruby-style path:
        #   good/fun/stuff
        #   Good::Fun::Stuff
        # produce the same results.
#        def extract_modules(name)
#          modules = name.include?('/') ? name.split('/') : name.split('::')
#          name    = modules.pop
#          path    = modules.map { |m| m.underscore }
#          file_path = (path + [name.underscore]).join('/')
#          nesting = modules.map { |m| m.camelize }.join('::')
#          [name, path, file_path, nesting, modules.size]
#        end
#
#        def inflect_names(name)
#          camel  = name.camelize
#          under  = camel.underscore
#          plural = under.pluralize
#          [camel, under, plural]
#        end
    end
  end
end
