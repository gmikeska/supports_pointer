require 'rails_helper'

RSpec.describe "settings_models/show", type: :view do
  before(:each) do
    assign(:settings_model, SettingsModel.create!(
      data: "Data"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Data/)
  end
end
