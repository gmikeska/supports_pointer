class BlogPost < ApplicationRecord
  include SupportsPointer

  pointer_parser :blogpost, Regexp::Template.new(atoms:[:"^",:"(?<slug>\w*)"])

  pointer_resolution :blogpost do |data|
    binding.pry
    BlogPost.find_by slug:data[:slug]
  end
end
