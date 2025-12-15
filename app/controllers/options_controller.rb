class OptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_option, only: %i[ show edit update destroy ]

  # GET /options or /options.json
  def index
    @options = Option.all
  end

  # GET /options/1 or /options/1.json
  def show
  end

  # GET /options/new
  def new
    @option = Option.new
  end

  # GET /options/1/edit
  def edit
  end

  # POST /options or /options.json
  def create
    @option = Option.new(option_params)

    respond_to do |format|
      if @option.save
        target_form = @option.field&.form
        if target_form
          format.html { redirect_to form_path(target_form), notice: "Option added." }
        else
          format.html { redirect_to options_path, notice: "Option was successfully created." }
        end
        format.json { render :show, status: :created, location: @option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /options/1 or /options/1.json
  def update
    respond_to do |format|
      if @option.update(option_params)
        format.html { redirect_to @option, notice: "Option was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /options/1 or /options/1.json
  def destroy
    @option.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@option) }
      target_form = @option.field&.form
      if target_form
        format.html { redirect_to form_path(target_form), notice: "Option was successfully destroyed.", status: :see_other }
      else
        format.html { redirect_to options_path, notice: "Option was successfully destroyed.", status: :see_other }
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_option
      @option = Option.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def option_params
      params.require(:option).permit(:field_id, :label, :value, :position)
    end
end
