FactoryBot.define do
  factory :blog_post do
    name { "Test Title" }
    body { "MyText" }
    association :author, factory: :user

  end
end
