require "core_ext/regexp"
require "supports_pointer/version"
require "supports_pointer/railtie"

module SupportsPointer
  MODEL_PARSER_ATOMS = [:"(?<model_name>\\w*)"]
  MODEL_INSTANCE_PARSER_ATOMS = [:"(?<model_name>\\w*):(?<param>\\w*)"]
  HANDLE_PARSER_ATOMS = [:"@",:"(?<handle>\\w*)"]
  extend ActiveSupport::Concern
  included do
    @@pointers = {}
    @@segments = {}
    def self.parses_pointer(name, **args)
      if(!!args[:template])
        if(args[:template].is_a?(Regexp::Template))
          @@pointers[name.to_sym] = {}
          @@pointers[name.to_sym][:matcher] = args[:template].rx
        elsif(args[:template].is_a?(Regexp))
          @@pointers[name.to_sym] = {}
          @@pointers[name.to_sym][:matcher] = args[:template]
        elsif(args[:template].is_a?(String))
          atoms = [:"{",:"(?<segment_name>\\w*)" ,:"}"]
          segment_matcher = Regexp::Template.new(atoms:atoms)
          segment_names = args[:template].scan(segment_matcher)
        end
      elsif(!args[:template] && SupportsPointer.const_defined?(name.to_s.upcase+"_PARSER_ATOMS"))
          @@pointers[name.to_sym] = {}
          @@pointers[name.to_sym][:matcher] = Regexp::Template.new(atoms:self.const_get((name.to_s.upcase+"_PARSER_ATOMS").to_sym)).rx
      end
    end

    def self.pointers
      return @@pointers
    end
    def self.pointer_types
      return @@pointers.keys
    end
    def self.is_pointer?(ptr)
      begin
        result = self.resolve_pointer(ptr)
      rescue
        return false
      end
      return true
    end

    def self.pointer_type(ptr)
      result = false
      @@pointers.each do |type, data|
        if(ptr.match(data[:matcher]))
          result = type
        end
      end
      return result
    end

    def self.parse_pointer(ptr)
      type = pointer_type(ptr)
      matcher = @@pointers[type][:matcher]
      result = ptr.match(matcher).named_captures.symbolize_keys
      result[:pointer_type] = type
      return result
    end

    def self.resolve_pointer(ptr)
      data = self.parse_pointer(ptr)
      @@pointers[data[:pointer_type]][:resolve].call(data)
    end

    def self.pointer_generation(&block)
      @pointer_generation = block
    end

    def self.pointer_resolution(name,&block)
      @@pointers[name.to_sym][:resolve] = block.to_proc
    end

    def self.to_pointer(object)
      if(@pointer_generation)
        return @pointer_generation.call(self)
      elsif(@mode == :split)
        return [object.class.name, object.id].join(":")
      end
    end

    def self.method_missing(m,*args, &block)
      if(@@pointers[m.match(/resolve_(?<name>\w*)/)["name"]])
        return @@pointers[m.match(/resolve_(?<name>\w*)/)["name"].to_sym][:resolve].call(*args)
      end
      # if(m.to_s.include? "generate_" &&  @segment_names.include?(m.to_s.split('_')[1]))
      #   @segments[m.to_s.split('_')[1]] = block
      # end
    end
    def to_pointer
      return self.class.pointer_generation.call(self)
    end
  end
end


# pointer_format /(?<model> \w*):(?<param>\w*)/

# pointer_format "{model_name}:{parameter}"
