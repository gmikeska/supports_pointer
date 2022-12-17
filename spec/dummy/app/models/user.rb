class User < ApplicationRecord
  parses_pointer :handle, template:/@(?<handle>\w*)/
  has_many :blog_posts, as: :author

  pointer_resolution :handle do |data|
    User.find_by handle:data[:handle]
  end
  pointer_generation :handle do |user|
    "@#{user.handle}"
  end

  def mention
    User.generate_handle_pointer(self)
  end

end
