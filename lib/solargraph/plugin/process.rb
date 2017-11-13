require 'json'

module Solargraph
  module Plugin
    class Process
      def run
        until STDIN.closed?
          input = gets
          break if input.nil?
          args = nil
          begin
            args = JSON.parse(input)
            case args['command']
            when 'require'
              STDOUT.puts do_require args['paths']
            when 'methods'
              STDOUT.puts get_methods args['params']
            when 'constants'
              STDOUT.puts get_constants args['params']
            else
              STDOUT.puts respond_err "Unrecognized command #{args['command']}"
            end
          rescue JSON::ParserError => e
            STDOUT.puts respond_err "Error parsing input: #{e.message}"
          end
          STDOUT.flush
        end
      end

      private

      def do_require paths
        errors = []
        paths.each do |p|
          begin
            STDERR.puts "Runtime plugin is requiring #{p}"
            require p
          rescue Exception => e
            errors.push "Failed to require #{p}: #{e.class} #{e.message}"
          end
        end
        if errors.empty?
          respond_ok
        else
          respond_err errors.join('; ')
        end
      end

      def get_methods args
        result = []
        con = find_constant(args['namespace'], args['root'])
        unless con.nil?
          if (args['scope'] == 'class')
            if args['with_private']
              result.concat con.methods
            else
              result.concat con.public_methods
            end
          elsif (args['scope'] == 'instance')
            if args['with_private']
              result.concat con.instance_methods
            else
              result.concat con.public_instance_methods
            end
          end
        end
        respond_ok result
      end

      def get_constants args
        result = []
        con = find_constant(args['namespace'], args['root'])
        unless con.nil?
          result.concat con.constants.map
        end
        respond_ok result
      end

      def find_constant(namespace, root)
        result = nil
        parts = root.split('::')
        until parts.empty?
          result = inner_find_constant("#{parts.join('::')}::#{namespace}")
          parts.pop
          break unless result.nil?
        end
        result = inner_find_constant(namespace) if result.nil?
        result
      end
      
      def inner_find_constant(namespace)
        cursor = Object
        parts = namespace.split('::')
        until parts.empty?
          here = parts.shift
          begin
            cursor = cursor.const_get(here)
          rescue NameError
            return nil
          end
        end
        cursor
      end

      def respond_ok data = []
        {
          status: 'ok',
          message: nil,
          data: data
        }.to_json
      end

      def respond_err msg
        {
          status: 'err',
          message: msg,
          data: []
        }.to_json
      end
    end
  end
end