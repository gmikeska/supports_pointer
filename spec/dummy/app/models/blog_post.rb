class BlogPost < ApplicationRecord
  has_one :config, as: :configurable

  before_save do |post|
    post.slug = post.name.parameterize.underscore
  end

  # parses_pointer :blog_post, template:Regexp::Template.new(atoms:[:"\\^",:"(?<slug>\\w*)"]).rx
  # pointer_resolution :blog_post do |data|
  #   BlogPost.find_by slug:data[:slug]
  # end
  # pointer_generation :blog_post do |data|
  #   "^#{data.slug}"
  # end

  def to_pointer
    return BlogPost.generate_blog_post_pointer(self)
  end
end
