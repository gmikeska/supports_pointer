require_relative "terminal"
module TerminalFormattingSupport
  def self.included(base)
    @terminal = Terminal.new()
  end
end
