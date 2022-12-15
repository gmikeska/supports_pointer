require 'rails_helper'

RSpec.describe "settings_models/new", type: :view do
  before(:each) do
    assign(:settings_model, SettingsModel.new(
      data: "MyString"
    ))
  end

  it "renders new settings_model form" do
    render

    assert_select "form[action=?][method=?]", settings_models_path, "post" do

      assert_select "input[name=?]", "settings_model[data]"
    end
  end
end
