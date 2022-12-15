class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include SupportsPointer
  
  parses_pointer :model
  parses_pointer :model_instance

end
