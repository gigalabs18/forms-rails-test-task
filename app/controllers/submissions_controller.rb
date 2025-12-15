class SubmissionsController < ApplicationController
  before_action :set_form
  before_action :set_submission, only: [:show]

  def index
    @submissions = @form.submissions.order(created_at: :desc)
  end

  def new
    @submission = @form.submissions.new
  end

  def create
    @submission = @form.submissions.new
    responses_hash = params[:responses] || {}

    # Basic validation for numeric fields
    errors = []
    @form.fields.ordered.each do |field|
      val = responses_hash[field.id.to_s]
      next if val.nil?
      if field.field_type == 'number'
        begin
          Float(val)
        rescue ArgumentError, TypeError
          errors << "#{field.label} must be a number"
        end
      end
    end

    if errors.any?
      flash.now[:alert] = errors.join(', ')
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      @submission.save!
      responses_hash.each do |field_id, value|
        next if value.nil?
        @submission.responses.create!(field_id: field_id, value: value)
      end
    end

    redirect_to form_submission_path(@form, @submission), notice: 'Submission recorded.'
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def show
    @responses = @submission.responses.includes(:field)
  end

  private
    def set_form
      @form = Form.find(params[:form_id])
    end

    def set_submission
      @submission = @form.submissions.find(params[:id])
    end
end
