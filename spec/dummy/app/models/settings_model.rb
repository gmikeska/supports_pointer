class SettingsModel < ApplicationRecord
  include SupportsPointer
  belongs_to :configurable, polymorphic: true
  serialize :data

  parses_pointer :key, parse:Proc.new{|key| return key.split('.') }
  pointer_generation :key do |data|
    result = []
    if(data[:domain] == data[:scope])
      result << data[:scope]
    else
      result << data[:domain]
      result << data[:scope]
    end
    if(!!data[:path] && data[:path].is_a?(Array))
      result << data[:path].join('.')
    elsif(!!data[:path])
      result << data[:path]
    end
    return result.join('.')
  end
  pointer_resolution :key do |data|
    User.find_by(handle:data[:handle].downcase)
  end
end
