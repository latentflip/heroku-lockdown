module Heroku
  module Command

    class LockedDownMethod < RuntimeError
      attr_accessor :command, :app
      def initialize(app, command)
        @app = app
        @command = command
      end
    end

    class << self
      alias_method :old_run, :run
      def run_catch_protected(*args)
        begin
          old_run(*args)
        rescue Heroku::Command::LockedDownMethod => pc
          error "The command: #{pc.command} has been locked down for app: #{pc.app} in your ~/.herokurc."
        end
      end
      alias_method :run, :run_catch_protected
    
      def run_internal(command, args, heroku=nil)
        klass, method = parse(command)
        runner = klass.new(args, heroku)
        raise InvalidCommand unless runner.respond_to?(method)
        raise ProtectedCommand.new(runner.app, command) if runner.respond_to?(:locked_down?) && runner.locked_down?(method)
        runner.send(method)
      end
    end

    class BaseWithApp
      attr_accessor :locked_down

      alias_method :old_initialize, :initialize
      def initialize(args, heroku=nil)
        old_initialize(args, heroku)
        @locked_down = {}
        lockdown_commands
      end
      
      alias_method :old_send, :send
      def safe_send(method, *args)
        if locked_down?(method)
          raise ProtectedCommand.new(app, method)
        end
      end
      alias_method :safe_send, :send

      def locked_down?(command)
        @locked_down[app] && @locked_down[app][self.class] && @locked_down[app][self.class].include?(command)
      end

      private
      def lockdown_commands
        f = File.open(ENV['HOME']+'/.herokurc', 'r').readlines
        f.each do |line|
          if /^protect/ === line
            pieces = line.split(' ')
            command = Heroku::Command.parse(pieces[2])
            @locked_down[pieces[1]] ||= {}
            @locked_down[pieces[1]][command[0]] ||= []
            @locked_down[pieces[1]][command[0]] << command[1]
          end
        end
      end
    end
  end
end

