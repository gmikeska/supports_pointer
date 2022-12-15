require "rails_helper"

RSpec.describe SettingsModelsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/settings_models").to route_to("settings_models#index")
    end

    it "routes to #new" do
      expect(get: "/settings_models/new").to route_to("settings_models#new")
    end

    it "routes to #show" do
      expect(get: "/settings_models/1").to route_to("settings_models#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/settings_models/1/edit").to route_to("settings_models#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/settings_models").to route_to("settings_models#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/settings_models/1").to route_to("settings_models#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/settings_models/1").to route_to("settings_models#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/settings_models/1").to route_to("settings_models#destroy", id: "1")
    end
  end
end
