module Heroku
  module Command

    class ProtectedCommand < RuntimeError
      attr_accessor :command, :app
      def initialize(app, command)
        @app = app
        @command = command
      end
    end

    class << self
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
        old_initialize(args, heroki)
        @locked_down = {}
        lockdown_commands
      }
      
      alias :old_send, :send
      def safe_send(method, *args)
        if locked_down?(method)
          raise ProtectedCommand.new(app, method)
        end
      end
      alias :safe_send, :send

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

