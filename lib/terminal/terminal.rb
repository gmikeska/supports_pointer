class Terminal
  FORMATTING = {
  reset:"0",
  reset_bold:"21",
  reset_muted:"22",
  reset_italic:"22",
  reset_underline:"24",
  reset_blink:"25",
  reset_inverted:"27",
  reset_hidden:"28",
  black_background: "40",
  dark_gray_background: "40",
  red_background: "41",
  light_red_background: "41",
  green_background: "42",
  light_green_background: "42",
  brown_orange_background: "43",
  yellow_background: "43",
  blue_background: "44",
  light_blue_background: "44",
  purple_background: "45",
  light_purple_background: "45",
  cyan_background: "46",
  light_cyan_background: "46",
  light_gray_background: "47",
  white_background: "47",
  bold: "1",
  muted: "2",
  italic: "3",
  underline: "4",
  blink: "5",
  inverted: "7",
  hidden: "8",
  font1: "11",
  font2: "12",
  font3: "13",
  font4: "14",
  font5: "15",
  black: "30",
  dark_gray: "30",
  red: "31",
  light_red: "31",
  green: "32",
  light_green: "32",
  brown_orange: "33",
  yellow: "33",
  blue: "34",
  light_blue: "34",
  purple: "35",
  light_purple: "35",
  cyan: "36",
  light_cyan: "36",
  light_gray: "37",
  framed: "51",
  encircled: "52",
}
  def initialize(**args)
    if(args[:color])
      @color = args[:color]
    else
      @color = :reset
    end
    if(args[:background])
      @background = args[:background]
    else
      @background = :reset_background
    end
  end

  def width(line,col)
    `tput cols`
  end

  def height(line,col)
    `tput lines`
  end

  def move_cursor_to(line,col)
    puts "\e[#{line};#{col}H"
  end

  def to_clipboard(clip_string,capture=false)
    if(has_app?("xsel"))
      if(!!capture)
        return `#{clip_string} | xsel -i`
      else
        return `echo #{clip_string} | xsel -i`
      end
    end
  end

  def from_clipboard
    if(has_app?("xsel"))
      return `xsel -o`
    end
  end

  def clear_clipboard
    if(has_app?("xsel"))
      return `xsel -c`
    end
  end

  def clear_terminal
    puts "\e[H\e[2J\e[3J"
  end

  def has_app?(app_name)
    return(`which #{app_name}` != "")
  end

  def build_formatting(name=:reset)
    if(!name.is_a? Array)
      name = [name]
    end
    return("\e[#{name.map{|n| Terminal::FORMATTING[n] }.join(';')}m")
  end

  def rbg(**args)
    if(!!args[:red])
      @red = args[:red]
    elsif(!!args[:r])
      @red = args[:r]
    end
    if(!!args[:blue])
      @blue = args[:blue]
    elsif(!!args[:b])
      @blue = args[:b]
    end
    if(!!args[:green])
      @green = args[:green]
    elsif(!!args[:g])
      @green = args[:g]
    end
    color_code = 16+(@red*36)+(@blue*1)+(@green*6)
    if(!!args[:text])
      return "\e[38;5;#{color_code}m#{args[:text]}#{build_formatting(:reset)}"
    else
      return color_code
    end
  end

  def add_formatting(text,name=:reset)
    if(!name.is_a?(Array))
      name = [name]
    end
    name.map do |n|
      if(name.to_s.match(/_(\d*)_/)) # ex: "_2_" for color 2.
        "\e[38;5;#{name.to_s.match(/_(\d*)_/)[1]}m#{text}#{build_formatting(:reset)}"
      else

        if(FORMATTING.keys
          .select{|k| k.to_s.include?("reset_")}.map{|k| k.to_s.split('_')[1]}
          .include?(name.to_s))
          reset_formatting = build_formatting("reset_#{name.to_s}".to_sym)
        else
          reset_formatting = build_formatting(:reset)

        end
        text = "#{build_formatting(name)}#{text}#{reset_formatting}"
      end
    end
    return text
  end

end
