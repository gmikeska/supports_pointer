class BlogPost < ApplicationRecord
  include SupportsPointer

  parses_pointer :blogpost, Regexp::Template.new(atoms:[:"^",:"(?<slug>\w*)"])

  pointer_resolution :blogpost do |data|
    BlogPost.find_by slug:data[:slug]
  end
end
