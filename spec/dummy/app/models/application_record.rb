class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include SupportsPointer

  parses_pointer :model
  parses_pointer :model_instance

  def self.to_pointer
    return self.generate_model_pointer(self)
  end
  def to_pointer
    return self.class.generate_model_instance_pointer(self)
  end
end
