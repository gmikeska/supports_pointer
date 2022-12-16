require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  let(:blog_post) { FactoryBot.create(:blog_post) }

  it "has a pointer" do
    expect(blog_post.to_pointer).to eq("#{blog_post.class.name}:#{blog_post.slug}")
  end

  it "can resolve pointers" do
    expect(BlogPost.resolve_pointer("BlogPost:#{blog_post.slug}")).to eq(blog_post)
  end
end
