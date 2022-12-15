class User < ApplicationRecord
  parses_pointer :handle, template:/@(?<handle>\w*)/
  
end
