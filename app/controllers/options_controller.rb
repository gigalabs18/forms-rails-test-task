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
        # Turbo: append option inline under its field
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "options_list_for_#{@option.field_id}",
              partial: "options/item",
              locals: { opt: @option }
            ),
            turbo_stream.replace(
              "new_option_form_for_#{@option.field_id}",
              partial: "options/new_form",
              locals: { field: @option.field, option: Option.new(field: @option.field) }
            )
          ]
        end
        # HTML fallback
        if target_form
          format.html { redirect_to form_path(target_form), notice: "Option added." }
        else
          format.html { redirect_to options_path, notice: "Option was successfully created." }
        end
        format.json { render :show, status: :created, location: @option }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_option_form_for_#{@option.field_id}",
            partial: "options/new_form",
            locals: { field: @option.field, option: @option }
          )
        end
        format.html do
          if @option.field&.form
            redirect_to form_path(@option.field.form), alert: @option.errors.full_messages.to_sentence
          else
            render :new, status: :unprocessable_entity
          end
        end
        format.json { render json: @option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /options/1 or /options/1.json
  def update
    respond_to do |format|
      if @option.update(option_params)
        # Turbo: replace the option item inline
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @option,
            partial: "options/item",
            locals: { opt: @option }
          )
        end
        # HTML fallback
        target_form = @option.field&.form
        if target_form
          format.html { redirect_to form_path(target_form), notice: "Option was successfully updated.", status: :see_other }
        else
          format.html { redirect_to @option, notice: "Option was successfully updated.", status: :see_other }
        end
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
      params.require(:option).permit(:field_id, :label, :value)
    end
end
