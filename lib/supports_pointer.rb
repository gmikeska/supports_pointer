require "core_ext/regexp"
require "core_ext/string"
require "supports_pointer/version"
require "supports_pointer/railtie"

module SupportsPointer
  MODEL_PARSER_ATOMS = [:"(?<model_name>\\w*)"]
  MODEL_RESOLVER = Proc.new{ |data| data[:model_name].classify.constantize }
  MODEL_GENERATOR = Proc.new{ |data| data.name }

  MODEL_INSTANCE_PARSER_ATOMS = [:"(?<model_name>\\w*):(?<param>\\w*)"]
  MODEL_INSTANCE_RESOLVER = Proc.new{ |data| data[:model_name].classify.constantize.find(data[:param]) }
  MODEL_INSTANCE_GENERATOR = Proc.new{ |data| "#{data.class.name}:#{data.to_param}" }

  HANDLE_PARSER_ATOMS = [:"@",:"(?<handle>\\w*)"]
  extend ActiveSupport::Concern
  included do
    @@pointers = {}
    @@segments = {}

    # Declares a pointer type on the current class object
    #
    # @param name [Symbol] the name of the pointer type (ie: :model, etc..)
    # @param args [Hash] the hash of pointer options to be declared for this pointer
    # @return [Hash] the pointer type's data hash.
    def self.parses_pointer(name, **args)
      if(!@@pointers[self.name.to_sym])
        @@pointers[self.name.to_sym] = {}
      end
      if(!@@pointers[self.name.to_sym][name.to_sym])
        @@pointers[self.name.to_sym][name.to_sym] = {}
      end

      if(!!args[:template])
        if(args[:template].is_a?(Regexp::Template))
          @@pointers[self.name.to_sym][name.to_sym][:matcher] = args[:template].rx
        elsif(args[:template].is_a?(Regexp))
          @@pointers[self.name.to_sym][name.to_sym] = {}
          @@pointers[self.name.to_sym][name.to_sym][:matcher] = args[:template]
        elsif(args[:template].is_a?(String))
          atoms = [:"{",:"(?<segment_name>\\w*)" ,:"}"]
          segment_matcher = Regexp::Template.new(atoms:atoms)
          segment_names = args[:template].scan(segment_matcher)
        end
      elsif(!args[:template] && SupportsPointer.const_defined?(name.to_s.upcase+"_PARSER_ATOMS"))
          @@pointers[self.name.to_sym][name.to_sym][:matcher] = Regexp::Template.new(atoms:self.const_get((name.to_s.upcase+"_PARSER_ATOMS").to_sym)).rx
          if(!args[:resolve])
            @@pointers[self.name.to_sym][name.to_sym][:resolve] = self.const_get(name.to_s.upcase+"_RESOLVER")
          end
          if(!args[:generate])
            @@pointers[self.name.to_sym][name.to_sym][:generate] = self.const_get(name.to_s.upcase+"_GENERATOR")
          end
      elsif(!args[:template] && !!args[:parse] )
          @@pointers[self.name.to_sym][name.to_sym][:parser] = args[:parse]
      end
      if(!!args[:resolve])
        @@pointers[self.name.to_sym][name.to_sym][:resolve] = args[:resolve]
      end
      if(!!args[:generate])
        @@pointers[self.name.to_sym][name.to_sym][:generate] = args[:generate]
      end
      return !!@@pointers[self.name.to_sym][name.to_sym]
    end

    # Grants the current class access to a pointer type from another class
    #
    # @param name [Symbol] the name of the pointer type (ie: :model, etc..)
    # @param args [Symbol] use :from to specify the class from which to grant access)
    # @return [Hash] the pointer type's data hash
    def self.uses_pointer(name, **args)
      parser = args[:from].pointers[name.to_sym]
      if(!@@pointers[self.name.to_sym])
        @@pointers[self.name.to_sym] = {}
      end
      if(!@@pointers[self.name.to_sym][name])
        @@pointers[self.name.to_sym][name] = parser
      end
      @@pointers[self.name.to_sym][name]
    end

    # Returns a hash of all pointers for a given instance's class
    #
    # @return [Hash] the data hash of all pointer types
    def pointers
      self.class.pointers
    end

    # Returns a hash of all pointers for a given class
    #
    # @return [Hash] the data hash of all pointer types
    def self.pointers
      if(!!@@pointers && !!@@pointers[self.name.to_sym])
        if(superclass.respond_to?(:pointers))
          return superclass.pointers.merge(@@pointers[self.name.to_sym])
        else
          return @@pointers[self.name.to_sym]
        end
      else
        if(superclass.respond_to?(:pointers))
          return superclass.pointers
        else
          return {}
        end
      end
    end

    # Returns an array of all pointer names declared on a class
    #
    # @return [Array] the array of pointer type names
    def self.pointer_types
      return self.pointers.keys
    end

    # Returns whether or not a particular string matches any known pointer type
    # @param ptr the string to be matched as a potential pointer
    # @return [Boolean] true if ptr is a pointer, false otherwise
    def self.is_pointer?(ptr)
      begin
        result = !!self.resolve_pointer(ptr)
      rescue
        return false
      end
      return result
    end

    # Returns the pointer type name for a particular string
    # @param ptr [String] the string to be matched against each pointer type
    # @return [Symbol] the string's pointer type name
    def self.pointer_type(ptr)
      result = nil
      self.pointers.each do |type, data|
        if(!!data[:matcher] && ptr.match(data[:matcher]))
          data = ptr.match(data[:matcher]).named_captures.symbolize_keys
          if(data.none?(""))
            result = type
          end
        elsif(!!data[:parser] && !!data[:parser].call(ptr))
          result = type
        end
      end
      return result
    end

    # Parses a pointer into a Hash of data ready for resolution
    # @param ptr [String] the string to be parsed as a pointer
    # @param args [Hash] use :type to specify the pointer type for parsing
    # @return [Hash] the data parsed from ptr
    def self.parse_pointer(ptr, **args)

      if(!!args[:type])
        type = args[:type]
      else
        type = pointer_type(ptr)
      end

      if(!!type)
        return self.send("parse_#{type.to_s}_pointer",ptr)
      else
        raise NameError.new("Unknown pointer type '#{pointer_name}'.", pointer_name)
      end
    end

    # Resolves a pointer into the referenced object
    # @param ptr [String] the string to be parsed as a pointer
    # @return the object referenced by ptr
    def self.resolve_pointer(ptr)
      data = self.parse_pointer(ptr)
      if(!!data && !!data[:type])
        return self.send("resolve_#{data[:type]}_pointer", data)
      end
    end

    # Updates the Proc object used to generate a pointer
    # @param name [Symbol] the pointer type to be updated
    # @param block the block to be used for pointer generation
    # @return [Hash] the pointer type's data hash
    def self.pointer_generation(name,&block)
      @@pointers[self.name.to_sym][name.to_sym][:generate] = block.to_proc
      @@pointers[self.name.to_sym][name.to_sym]
    end

    # Updates the Proc object used to resolve a pointer
    # @param name [Symbol] the pointer type to be updated
    # @param block the block to be used for pointer resolution
    # @return [Hash] the pointer type's data hash
    def self.pointer_resolution(name,&block)
      @@pointers[self.name.to_sym][name.to_sym][:resolve] = block.to_proc
      @@pointers[self.name.to_sym][name.to_sym]
    end
    # Implements the parse, resolve and generate behavior for each pointer type
    # @param m [Symbol] the method name being called (such as ```generate_model_pointer```)
    # @param args [Hash] the arguments being passed to the called method
    # @return the return value for the called method
    def self.method_missing(m,*args)

      if(m.to_s.match?(/resolve_(?<pointer_name>\w*)_pointer/))
        pointer_name = m.to_s.match(/resolve_(?<pointer_name>\w*)_pointer/)[:pointer_name]
        if(self.pointers.keys.include?(pointer_name.to_sym))
          if(args[0].is_a? Hash)
            return self.pointers[pointer_name.to_sym][:resolve].call(args[0])
          elsif(args[0].is_a? String)
            return self.pointers[pointer_name.to_sym][:resolve].call(self.send("parse_#{pointer_name}_pointer", args[0]))
          end
        else
          raise NameError.new("Unknown pointer type. Pointer type '#{pointer_name}' not defined in #{self.name}.", pointer_name)
        end
      end

      if(m.to_s.match?(/generate_(?<pointer_name>\w*)_pointer/))
        pointer_name = m.to_s.match(/generate_(?<pointer_name>\w*)_pointer/)[:pointer_name]
        if(self.pointers.keys.include?(pointer_name.to_sym) && !!self.pointers[pointer_name.to_sym][:generate])
          return self.pointers[pointer_name.to_sym][:generate].call(args[0])
        else
          raise NameError.new("Unknown pointer type. Pointer type '#{pointer_name}' not defined in #{self.name}.", pointer_name)
        end
      end


      if(m.to_s.match?(/parse_(?<pointer_name>\w*)_pointer/))
        pointer_name = m.to_s.match(/parse_(?<pointer_name>\w*)_pointer/)[:pointer_name]

        if(self.pointers.keys.include?(pointer_name.to_sym))
          if(!!self.pointers[pointer_name.to_sym][:matcher])
            data = args[0].match(self.pointers[pointer_name.to_sym][:matcher]).named_captures.symbolize_keys
          elsif(!!self.pointers[pointer_name.to_sym][:parser])
            data = self.pointers[pointer_name.to_sym][:parser].call(args[0])
          end
          data[:type] = pointer_name
          return data
        else
          raise NameError.new("Unknown pointer type. Pointer type '#{pointer_name}' not defined in #{self.name}.", pointer_name)
        end
      end
      # if(m.to_s.include? "generate_" &&  @segment_names.include?(m.to_s.split('_')[1]))
      #   @segments[m.to_s.split('_')[1]] = block
      # end
    end
  end
end
