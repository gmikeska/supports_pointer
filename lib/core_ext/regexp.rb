require_relative "../terminal/terminal_formatting_support"

class Regexp
  def append(other_regex)
    if(other_regex.is_a? Regexp)
      other_string = other_regex.source
    else
      other_string = other_regex.to_s
    end
    Regexp.new(self.source+other_string)
  end
  def prepend(other_regex)
    if(other_regex.is_a? Regexp)
      other_string = other_regex.source
    else
      other_string = other_regex.to_s
    end
    Regexp.new(other_string+self.source)
  end
  def template
    if(!@template)
      @template = Regexp::Template.new(source:self.source)
    end
    return @template
  end
  class Template
    include TerminalFormattingSupport
    MATCHERS = {
      any:".",
      alpha:"[a-zA-Z]",
      numeric:"\\d",
      nonnumeric:"\\D",
      alphanumeric:"\\w",
      nonalphanumeric:"\\W",
      whitespace:"\\s",
      nonwhitespace:"\\S",
      line_start:"^",
      line_end:"$"
    }
    TYPE_MATCHER_DEFAULTS = {
      string:".*",
      integer:"\\d*",
      decimal:"(\\d*.?\\d*)",
    }
    attr_reader :rx, :atoms
    def self.capture_group(atoms,**args)
      return Regexp::Template.new(atoms:[:placeholder_template]).capture_group(atoms,**args)
    end

    def initialize(**args)
      if(args.keys.length == 0)
        @rx = Regexp.new("")
      elsif(args[:source_rx].is_a?(String))
        @rx = Regexp.new(args[:source_rx])
      elsif(args[:source_rx].is_a?(Regexp))
        @rx = args[:source_rx]
      elsif(!!args[:atoms] && args[:atoms].is_a?(Array))
        @atoms = args[:atoms]
        set_regex_from_atoms
      end
      @type_matchers = {}.merge(Template::TYPE_MATCHER_DEFAULTS)

      if(!@atoms)
        self.analyze
      end
    end
    def set_regex_from_atoms
      @rx = Regexp.new(@atoms.map{|a| render_atom(a) }.join(""))
    end
    def push(o)
      if(o.is_a? Regexp)
        o = o.source
      elsif(o.is_a? Regexp::Template)
        o = o.rx.source
      end
      @atoms << o
      set_regex_from_atoms
    end
    def <<(o)
      self.push(o)
    end
    def types
      return @type_matchers.keys
    end
    def add_type(type_name, matcher)
      @type_matchers[type_name.to_sym] = matcher
    end
    def preview(parent_type=nil)
      numbering = @atoms.map.with_index do |a, index|
        atom_text = render_atom(a)
        # source = @rx.source.gsub(atom_text, atom_text+"|")
        # spacer_count = (atom_text+"|").length/2
        spacer_count = (atom_text).length/2
        "#{" "*(spacer_count-1)}##{index}#{" "*(spacer_count)}"
      end
      @terminal = Terminal.new()
      @terminal.clear_terminal
      rx_source = @rx.source
      descriptions = []
      if(!parent_type)
        @atoms.map.with_index do |a,index|
          if(a.is_a?(Array) && a[0] == :"(" && a[a.length-1] == :")")
            stringified = a.map(&:to_s).join('')
            rx_source = rx_source.gsub(stringified,@terminal.rbg(r:0,b:0,g:5, text:stringified))
            subatoms = a[1,a.length-2]
            if(subatoms[0].to_s.start_with?("?<"))
              name = subatoms.shift
              name = name.to_s.match(/\?\<(?<name>.*)\>/)[:name]
              name = "#{name}"
            else
              name = "anonymous_capture_group"
            end
            if(subatoms.length == 1)
              a =  "#{@terminal.rbg(r:0,b:0,g:5, text:"Capture group \"#{name}\"")} captures #{self.describe(subatoms.first)}"
            elsif(subatoms.length == 2)
              a =    "#{@terminal.rbg(r:0,b:0,g:5, text:"Capture group \"#{name}\"")} captures #{self.describe(subatoms[0])} and #{self.describe(subatoms[0])}"
            else
              subatoms = subatoms.map{|s| self.describe(s)}
              last_subatom = subatoms.pop
            a =    "#{@terminal.rbg(r:0,b:0,g:5, text:"Capture group \"#{name}\"")} captures #{subatoms.join(',')} and #{last_subatom}"
            end
          else
            rx_source = rx_source.gsub(a.to_s,@terminal.rbg(r:0,b:5,g:1, text:a.to_s))
            a =  "#{@terminal.rbg(r:0,b:5,g:1, text:"\"#{a}\"")} matches #{self.describe(a)}"
          end
          descriptions << "##{index}. #{a}"
        end
      elsif(parent_type == :capture)
        @atoms.map do |a|
          if(a.to_s.include?("literal_"))
            "#{a.to_s.gsub("_"," ")}"
          elsif(a.to_s[0] == "(" && a.to_s[a.length-1] == ")")
            "#{self.preview(a.to_s[1,a.length-1],:capture)}"
          elsif(a.to_s[0] == "\\" && matchers.keys.include?(a.to_s[1]))
            "#{matchers[a]}"
          elsif(a.to_s[0] == "\\" && a.length <= 3 && !matchers.keys.include?(a.to_s[1]))
            "literal #{a}"
          else
            "#{a}"
          end
        end
      end
      indent = 1
      indent_str = "\t"*indent
      puts "\n"*2
      puts "#{indent_str}#{rx_source}"
      puts "#{indent_str}#{@terminal.add_formatting(numbering.join(''), :yellow)}"
      descriptions.each{|desc| puts "#{indent_str}#{desc}" }
      return
    end
    def describe(atom)
      matchers = {}
      match_count = "exactly 1 instance"
      if(atom.to_s[atom.to_s.length-1] == "*")
        match_count = "any number of"
      elsif(atom.to_s[atom.to_s.length-1] == "?")
        match_count = "zero or one"
      elsif(atom.to_s[atom.to_s.length-1] == "+")
        match_count = "1 or more"
      elsif(atom.to_s.match(/\{(?<count>.*)\}\z/))
        match_count_data = atom.to_s.match(/\{(?<count>.*)\}\z/)[:count]
        if(match_count_data.split(',').length == 2)
          match_count = "between #{match_count_data.split(',').first} and #{match_count_data.split(',').last}"
        elsif(match_count_data > 1)
          match_count = "exactly #{match_count_data}"
        end
      end

      if(atom.to_s.include?("literal_"))
        desc = "#{atom.to_s.gsub("_"," ")}"
        color= :yellow
      elsif(atom.to_s[0] == "(" && atom.to_s[atom.length-1] == ")")
        desc = "#{self.preview(atom.to_s[1,atom.length-1],:capture)}"
      elsif(atom.to_s[0] == "\\" && self.class::MATCHERS.keys.include?(atom.to_s[1]))
        desc = "#{self.class::MATCHERS[atom.to_s[1]]} characters"
        color= :yellow
      elsif(@type_matchers.values.include?(atom.to_s))
        matcher_name = (@type_matchers.select{|k| @type_matchers[k] == atom.to_s}.first).first.to_s
        desc  = "#{matcher_name}"
        type_matcher = true
        color = {r:4,b:0,g:4}
      elsif(atom.to_s[0] == "\\" && atom.length <= 3 && !self.class::MATCHERS.keys.include?(atom.to_s[1]))
        desc = "literal #{atom}"
        color= :yellow
      else
        desc = @terminal.rbg(r:0,b:5,g:0, text:"\"#{atom}\"")
      end
      if(!type_matcher)
        desc = "#{match_count} of #{@terminal.add_formatting(desc, color)}"
        return desc.gsub(" of of "," of ")
      else
        desc[0] = desc[0].upcase
        if("aeiou".include?(desc[0,1].downcase))
          article = "an"
        else
          article = "a"
        end
        if(!!color && color.is_a?(Hash))
          color[:text] = desc
          desc = "#{article} #{@terminal.rbg(**color)}"
        elsif(!!color)
          desc = "#{article} #{@terminal.add_formatting(desc, color)}"
        else
          desc = "#{article} #{desc}."
        end
      end
    end
    def analyze
      if(!!@rx && !!@rx.source)
        src = @rx.source
      end

      current_segment = ""
      current_atom = {}
      atom_complete = false
      while(!atom_complete)
        src.split('').each do |char|
          current_segment = "#{current_segment}#{char}"
          if(char == "\\")
            current_atom[:escaped] = true
          end
          if(char == ".")
            current_atom[:match] = :any
          end
          if(char == "*")
            current_atom[:count] = :any
          end
        end
      end
    end

    def get_atom(**args)
      self.class.get_atom(**args)
    end

    def self.get_atom(**args)     # args[:match] ":any, :numeric, :alphanumeric, etc, also ex: :except_numeric"
                                  # args[:count] see self.count
                                  # args[:string] for 'literal' text to be matched
      if(!args[:types])
        args[:types] = TYPE_MATCHER_DEFAULTS
      else
        args[:types] = args[:types]
      end

      result = ""
      if(!!args[:match])

        if(args[:match].to_s.include?('except_'))
          args[:match] = args[:match].split("_")[1]
          except = true
        else
          except = false
        end
        if(MATCHERS.keys.include?(args[:match]))
          result = MATCHERS[args[:match].to_sym]
          if(!!args[:count])
            result = "#{result}#{self.count(args[:count])}"
          end
        elsif(args[:types].keys.include?(args[:match]))
          result = "#{args[:types][args[:match].to_sym].to_s}"
        end
      elsif(!!args[:string])
        if(args[:string].length == 2 && args[:string] == Regexp.escape(args[:string][1]))
          result = "literal_#{args[:string][1]}"
        else
          result = args[:string]
        end
      end

      if(!!except)
        result = "[^#{result}]"
      end
      return result.to_sym
    end

    def render_atom(atom)
      if(atom.is_a? Array)
        atom = atom.map(&:to_s).join('')
      end
      atom_str = atom.to_s
      if(atom_str.include?("literal_"))
        return self.escape(atom_str.split("_").last)
      else
        return atom_str
      end
    end
    def literal(atom_string)
      return "#{self.escape(atom_string.to_s)}"
    end
    def line_start
      return "^"
    end
    def line_end
      return "$"
    end
    def count(count)
      self.class.count(count)
    end
    def self.count(count)
      if(count == :any)
        return "*"
      end
      # if(count.is_a? Symbol)
      if(count.to_s.match(/\>(?<count>\d*)$/))
        count_number = count.to_s.match(/\>(?<count>\d*)/)[:count].to_i
        return "+" if(count_number == 0)
        return "{#{count_number},}"
      elsif(count.to_s.match(/0_or_1/))
        return "?"
      elsif(count.to_s.match(/\>(?<count_min>\d*)_\<(?<count_max>\d*)/)) # Example: count(">3_<5".to_sym) for "greater than 3 less than 5"
        counts = count.match(/\>(?<count_min>\d*)_\<(?<count_max>\d*)/)
        count_min = counts[:count_min].to_i
        count_max = counts[:count_max].to_i
        return "{#{count_min},#{count_max}}"
      elsif(count.to_s.match(/(?<count>\d*)/))
        return"{#{count.to_s.match(/(?<count>\d*)/)[:count].to_i}}"
      end
    end
    def capture_group(atoms,**args)
      if(!atoms.is_a?(Array))
        atoms = [atoms]
      end
      if(args[:name])
        atoms.unshift("?<#{args[:name]}>".to_sym)
      end
      atoms.unshift(:"(")
      atoms.push(:")")
      def atoms.to_sym
        self.map{|a| render_atom(a) }.join('').to_sym
      end
      return atoms
    end
    def group(atoms)
      return "[#{atoms.join("")}]"
    end
  end
end
