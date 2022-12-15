require 'rails_helper'

RSpec.describe "settings_models/edit", type: :view do
  let(:settings_model) {
    SettingsModel.create!(
      data: "MyString"
    )
  }

  before(:each) do
    assign(:settings_model, settings_model)
  end

  it "renders the edit settings_model form" do
    render

    assert_select "form[action=?][method=?]", settings_model_path(settings_model), "post" do

      assert_select "input[name=?]", "settings_model[data]"
    end
  end
end
