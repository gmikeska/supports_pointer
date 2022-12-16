class BlogPost < ApplicationRecord
  has_one :config, as: :configurable

  before_save do |post|
    post.slug = post.name.parameterize.underscore
  end

  def to_param
    slug
  end
  def self.find(arg)
    if(arg.to_i == 0 && arg != "0")
      return find_by slug:arg
    else
      super(arg)
    end
  end
  # parses_pointer :blog_post, template:Regexp::Template.new(atoms:[:"\\^",:"(?<slug>\\w*)"]).rx
  # pointer_resolution :blog_post do |data|
  #   BlogPost.find_by slug:data[:slug]
  # end
  # pointer_generation :blog_post do |data|
  #   "^#{data.slug}"
  # end


end
