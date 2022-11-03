require 'rails_helper'

RSpec.describe "blog_posts/index", type: :view do
  before(:each) do
    assign(:blog_posts, [
      BlogPost.create!(
        name: "Name",
        body: "MyText"
      ),
      BlogPost.create!(
        name: "Name",
        body: "MyText"
      )
    ])
  end

  it "renders a list of blog_posts" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
