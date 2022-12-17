class CreateBlogPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :blog_posts do |t|
      t.string :name
      t.string :slug, uniqe:true
      t.text :body
      t.belongs_to :author
      t.timestamps
    end
  end
end
