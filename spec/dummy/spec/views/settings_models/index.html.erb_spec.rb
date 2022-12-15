require 'rails_helper'

RSpec.describe "settings_models/index", type: :view do
  before(:each) do
    assign(:settings_models, [
      SettingsModel.create!(
        data: "Data"
      ),
      SettingsModel.create!(
        data: "Data"
      )
    ])
  end

  it "renders a list of settings_models" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Data".to_s), count: 2
  end
end
