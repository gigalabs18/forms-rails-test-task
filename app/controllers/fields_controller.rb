class FieldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_field, only: %i[ show edit update destroy ]

  # GET /fields or /fields.json
  def index
    @fields = Field.all
  end

  # GET /fields/1 or /fields/1.json
  def show
  end

  # GET /fields/new
  def new
    if params[:form_id].blank?
      redirect_to forms_path, alert: "Open a form and click Add field." and return
    end
    @field = Field.new
    # Preselect form and field type if provided (e.g., from "Add select field" link)
    @field.form_id = params[:form_id]
    preset_type = params[:field_type] || params[:type]
    @field.field_type = preset_type if preset_type.present?
  end

  # GET /fields/1/edit
  def edit
  end

  # POST /fields or /fields.json
  def create
    @field = Field.new(field_params)

    respond_to do |format|
      # Gather any initial options from params in a safe, whitelisted way
      permitted_opts = params.permit(options: [ :label, :value ])[:options]
      initial_options = (permitted_opts || {}).values
      present_options = initial_options.select { |opt| opt[:label].to_s.strip.present? }

      # Validation: Select fields must include at least one option
      if @field.type_select? && present_options.empty?
        @field.errors.add(:base, "Select fields must include at least one option")
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "addQuestionCardBody",
            partial: "fields/add_card_body",
            locals: { field: @field }
          ), status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      elsif @field.save
        # If select type, create options from structured params (label/value pairs)
        if @field.type_select?
          used_values = {}
          present_options.each do |opt|
            label = opt[:label].to_s.strip
            value = opt[:value].to_s.strip
            next if label.blank?
            value = value.presence || label.parameterize
            next if used_values[value]
            used_values[value] = true
            @field.options.create(label: label, value: value)
          end
        end
        # Turbo: append new builder card inline on the form page
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "fields_table_body",
            partial: "fields/builder_card",
            locals: { field: @field }
          )
        end
        # HTML fallback: redirect to the parent form's show page
        target = @field.form_id.present? ? form_path(@field.form_id) : fields_path
        format.html { redirect_to target, notice: "Field was successfully created." }
        format.json { render :show, status: :created, location: @field }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "addQuestionCardBody",
            partial: "fields/add_card_body",
            locals: { field: @field }
          ), status: :unprocessable_entity
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fields/1 or /fields/1.json
  def update
    # If the field is already a select without options, prevent updating it further
    # unless the change is switching away from select. This enforces that select
    # fields must always have at least one option.
    if @field.type_select? && @field.options.none?
      new_type = field_params[:field_type]
      if new_type.nil? || new_type == "select"
        respond_to do |format|
          format.turbo_stream do
            target_id = view_context.dom_id(@field, :card)
            render turbo_stream: turbo_stream.replace(
              target_id,
              partial: "fields/builder_card",
              locals: { field: @field, inline_alert: "Select fields must include at least one option" }
            ), status: :unprocessable_entity
          end
          target = @field.form_id.present? ? form_path(@field.form_id) : fields_path
          format.html { redirect_to target, alert: "Select fields must include at least one option" }
          format.json { render json: { error: "Select fields must include at least one option" }, status: :unprocessable_entity }
        end
        return
      end
    end

    respond_to do |format|
      if @field.update(field_params)
        target = @field.form_id.present? ? form_path(@field.form_id) : fields_path
        format.turbo_stream do
          target_id = view_context.dom_id(@field, :card)
          render turbo_stream: turbo_stream.replace(
            target_id,
            partial: "fields/builder_card",
            locals: { field: @field, inline_notice: "Question updated" }
          )
        end
        format.html { redirect_to target, notice: "Field was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @field }
      else
        format.turbo_stream do
          target_id = view_context.dom_id(@field, :card)
          render turbo_stream: turbo_stream.replace(
            target_id,
            partial: "fields/builder_card",
            locals: { field: @field, inline_alert: @field.errors.full_messages.to_sentence }
          ), status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1 or /fields/1.json
  def destroy
    @form = @field.form
    card_id = view_context.dom_id(@field, :card)
    @field.destroy!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(card_id)
      end
      format.html { redirect_to form_path(@form), notice: "Field was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_field
      @field = Field.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def field_params
      params.require(:field).permit(:form_id, :label, :field_type, :required)
    end
end
