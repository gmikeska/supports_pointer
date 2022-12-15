require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/settings_models", type: :request do
  
  # This should return the minimal set of attributes required to create a valid
  # SettingsModel. As you add validations to SettingsModel, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      SettingsModel.create! valid_attributes
      get settings_models_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      settings_model = SettingsModel.create! valid_attributes
      get settings_model_url(settings_model)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_settings_model_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      settings_model = SettingsModel.create! valid_attributes
      get edit_settings_model_url(settings_model)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new SettingsModel" do
        expect {
          post settings_models_url, params: { settings_model: valid_attributes }
        }.to change(SettingsModel, :count).by(1)
      end

      it "redirects to the created settings_model" do
        post settings_models_url, params: { settings_model: valid_attributes }
        expect(response).to redirect_to(settings_model_url(SettingsModel.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new SettingsModel" do
        expect {
          post settings_models_url, params: { settings_model: invalid_attributes }
        }.to change(SettingsModel, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post settings_models_url, params: { settings_model: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested settings_model" do
        settings_model = SettingsModel.create! valid_attributes
        patch settings_model_url(settings_model), params: { settings_model: new_attributes }
        settings_model.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the settings_model" do
        settings_model = SettingsModel.create! valid_attributes
        patch settings_model_url(settings_model), params: { settings_model: new_attributes }
        settings_model.reload
        expect(response).to redirect_to(settings_model_url(settings_model))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        settings_model = SettingsModel.create! valid_attributes
        patch settings_model_url(settings_model), params: { settings_model: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested settings_model" do
      settings_model = SettingsModel.create! valid_attributes
      expect {
        delete settings_model_url(settings_model)
      }.to change(SettingsModel, :count).by(-1)
    end

    it "redirects to the settings_models list" do
      settings_model = SettingsModel.create! valid_attributes
      delete settings_model_url(settings_model)
      expect(response).to redirect_to(settings_models_url)
    end
  end
end
