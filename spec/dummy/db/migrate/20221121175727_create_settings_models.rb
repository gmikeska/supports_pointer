class CreateSettingsModels < ActiveRecord::Migration[7.0]
  def change
    create_table :settings_models do |t|
      t.string :data
      t.timestamps
    end
  end
end
