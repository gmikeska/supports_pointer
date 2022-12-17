class BlogPost < ApplicationRecord
  has_one :config, as: :configurable
  belongs_to :author, class_name:"User",optional:true

  uses_pointer :handle, from:User

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


end
