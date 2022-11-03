require 'rails_helper'

RSpec.describe "blog_posts/new", type: :view do
  before(:each) do
    assign(:blog_post, BlogPost.new(
      name: "MyString",
      body: "MyText"
    ))
  end

  it "renders new blog_post form" do
    render

    assert_select "form[action=?][method=?]", blog_posts_path, "post" do

      assert_select "input[name=?]", "blog_post[name]"

      assert_select "textarea[name=?]", "blog_post[body]"
    end
  end
end
