class SettingsModelsController < ApplicationController
  before_action :set_settings_model, only: %i[ show edit update destroy ]

  # GET /settings_models
  def index
    @settings_models = SettingsModel.all
  end

  # GET /settings_models/1
  def show
  end

  # GET /settings_models/new
  def new
    @settings_model = SettingsModel.new
  end

  # GET /settings_models/1/edit
  def edit
  end

  # POST /settings_models
  def create
    @settings_model = SettingsModel.new(settings_model_params)

    if @settings_model.save
      redirect_to @settings_model, notice: "Settings model was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /settings_models/1
  def update
    if @settings_model.update(settings_model_params)
      redirect_to @settings_model, notice: "Settings model was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /settings_models/1
  def destroy
    @settings_model.destroy
    redirect_to settings_models_url, notice: "Settings model was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings_model
      @settings_model = SettingsModel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def settings_model_params
      params.require(:settings_model).permit(:data)
    end
end
