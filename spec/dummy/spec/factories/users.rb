FactoryBot.define do
  factory :user do
    email { "dude@dude.com" }
    handle { "dude" }
    password { "MyString" }
  end
end
