class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_form, only: %i[ show edit update destroy regenerate_link ]
  before_action :authorize_owner!, only: %i[ show edit update destroy regenerate_link ]

  # POST /forms/:id/regenerate_link
  def regenerate_link
    @form.regenerate_public_token!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "public_link_card",
          partial: "forms/public_link_card",
          locals: { form: @form }
        )
      end
      format.html { redirect_to @form, notice: "Public link regenerated." }
    end
  end

  # GET /forms or /forms.json
  def index
    @forms =
      if current_user.super_admin?
        Form.all
      else
        Form.where(user_id: current_user.id)
      end
  end

  # GET /forms/1 or /forms/1.json
  def show
  end

  # GET /forms/new
  def new
    @form = Form.new
  end

  # GET /forms/1/edit
  def edit
  end

  # POST /forms or /forms.json
  def create
    @form = Form.new(form_params)
    @form.user ||= current_user if user_signed_in?

    respond_to do |format|
      if @form.save
        format.html { redirect_to @form, notice: "Form was successfully created." }
        format.json { render :show, status: :created, location: @form }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /forms/1 or /forms/1.json
  def update
    respond_to do |format|
      if @form.update(form_params)
        format.html { redirect_to @form, notice: "Form was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forms/1 or /forms/1.json
  def destroy
    @form.destroy!

    respond_to do |format|
      format.html { redirect_to forms_path, notice: "Form was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form
      # For super admins, allow access to any form; otherwise scope to current user's forms
      @form = current_user.super_admin? ? Form.find(params[:id]) : current_user.forms.find(params[:id])
    end

    # Returns a scoped relation for forms based on the current user's role.
    def current_user_forms
      current_user.super_admin? ? Form : current_user.forms
    end

    # Simple owner authorization to guard direct access (e.g., regenerate_link)
    def authorize_owner!
      form = @form || Form.find(params[:id])
      unless current_user.super_admin? || form.user_id == current_user.id
        redirect_to forms_path, alert: "You are not authorized to access that form."
      end
    end

    # Only allow a list of trusted parameters through.
    def form_params
      params.require(:form).permit(:title)
    end
end
