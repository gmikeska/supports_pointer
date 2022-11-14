class String
  def select(**args)
    args[:parent] = self
    Selection.new(**args)
  end

  class Selection
    attr_accessor :parent, :cursor, :length, :value
    def initialize(**args)
      @parent = args[:parent]
      @cursor = args[:cursor].to_i
      @value = @parent[@cursor,args[:length]]
    end

    def length
      @value.length
    end

    def inspect
      return source
    end

    def source
      @parent[self.cursor,self.length]
    end

    def source=(replacement)
      @parent[self.cursor,self.length] = replacement
      @value = @parent[self.cursor,replacement.length]
    end


    def method_missing(m,*args, &block)
      if(!args)
        args = []
      end
      @value.send(m,*args,&block) # preplay action on @value to maintain length
      if(!!args[0] && args[0].is_a?(Integer))
        args[0] = @cursor+args[0]
        @parent.send(m,*args,&block)
      else
        source.send(m,*args,&block)
      end
    end
  end
end
