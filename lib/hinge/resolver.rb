module Hinge
  class Resolver
    Error = Class.new(RuntimeError)
    UnknownDependency = Class.new(Error)
    CircularReference = Class.new(Error)

    def initialize(container)
      @container = container
      @nodes = {}
      @resolved = {}
    end
    attr_reader :container
    attr_reader :resolved

    def resolve(name)
      return resolved[name] if resolved.key?(name)

      raise ArgumentError unless name.is_a?(Symbol)

      node = node(name)
      populate_node(node)

      resolved[name]
    end

    private

    def populate_node(node, history = [])
      unless node.method
        complain(UnknownDependency, node, history, "method #{node.method_name} not found")
      end
      if history.include?(node.name)
        complain(CircularReference, node, history, "dependency #{node.name} depends on itself")
      end

      node.dependency_names.each do |dep_name|
        populate_node node(dep_name), history + [node.name] unless @resolved[dep_name]
      end

      ordered_dependent_values =
        node.dependency_names.map do |dep_name|
          @resolved[dep_name]
        end
      @resolved[node.name] = node.invoke(ordered_dependent_values)
    end

    def complain(exn, node, history, msg = "")
      raise exn, "#{msg} (resolving #{[*history, node.name].join(" -> ")})"
    end

    def node(name)
      @nodes[name] ||= Node.new(name, container)
    end

    class Node
      def initialize(name, container)
        @name = name
        @method_name = "build_#{@name}"
        @method =
          begin
            container.method(@method_name)
          rescue NameError
            nil
          end

        if @method
          @dependency_names = []
          @positional_args_count = 0
          @keyword_arg_names = []

          @method.parameters.each do |kind, argument_name|
            argument_name = argument_name.to_sym
            @dependency_names << argument_name
            case kind
            when :req
              @positional_args_count += 1
            when :keyreq
              @keyword_arg_names << argument_name
            end
          end
        end
      end
      attr_reader :name, :method_name, :method, :dependency_names

      def invoke(ordered_values)
        splat = ordered_values.take(@positional_args_count)
        splat << Hash[
          @keyword_arg_names.zip(ordered_values.drop(@positional_args_count))
        ] if @keyword_arg_names.any?
        @method.call(*splat)
      end
    end
  end
end

