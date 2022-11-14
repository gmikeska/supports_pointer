class BlogPost < ApplicationRecord
  include SupportsPointer

  before_save do |post|
    post.slug = post.name.parameterize.underscore
  end

  parses_pointer :blogpost, template:Regexp::Template.new(atoms:[:"\\^",:"(?<slug>\\w*)"]).rx

  pointer_generation :blogpost do |data|
    "^#{data.slug}"
  end

  pointer_resolution :blogpost do |data|
    BlogPost.find_by slug:data[:slug]
  end

  def to_pointer
    return BlogPost.generate_blogpost_pointer(self)
  end
end
