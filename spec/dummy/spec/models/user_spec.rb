require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a pointer" do
    user = create(:user)
    user.handle = "dude"; user.save
    expect(user.to_pointer).to eq("#{user.class.name}:#{user.id}")
  end

  it "can resolve pointers" do
    user = create(:user)
    user.handle = "dude"; user.save
    expect(User.resolve_pointer("User:#{user.id}")).to eq(user)
  end

  it "has a handle pointer" do
    expect(User.pointer_types).to include(:handle)
  end

  it "generates mentions" do
    u = create(:user)
    u.handle = "dude"; u.save
    expect(u.mention).to eq("@dude")
  end

  it "can resolve handle pointers" do
    expect(User.resolve_pointer("@dude")).to eq(User.find_by handle:"dude")
  end
end
