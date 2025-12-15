class SubmissionsController < ApplicationController
  before_action :set_form
  before_action :authenticate_user!, only: [:index, :show]
  before_action :ensure_owner!, only: [:index, :show]
  before_action :set_submission, only: [:show]

  def index
    @submissions = @form.submissions.order(created_at: :desc)
  end

  def new
    @submission = @form.submissions.new
  end

  def create
    @submission = @form.submissions.new
    responses_hash = if params[:responses].present?
                        # Permit dynamic response keys (field ids) coming from the public form
                        params.require(:responses).permit!.to_h
                      else
                        {}
                      end

    errors = validate_responses(responses_hash)
    return render(:new, status: :unprocessable_entity) if surfaced_errors?(errors)

    ActiveRecord::Base.transaction do
      @submission.save!
      responses_hash.each do |field_id, value|
        next if value.nil?
        @submission.responses.create!(field_id: field_id, value: value)
      end
    end

    if user_signed_in?
      redirect_to form_submission_path(@form, @submission), notice: 'Submission recorded.'
    else
      redirect_to fill_form_path(@form.public_token), notice: 'Thanks! Your response has been recorded.'
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def show
    @responses = @submission.responses.includes(:field)
  end

  private
    def validate_responses(responses_hash)
      errs = []
      @form.fields.ordered.each do |field|
        val = responses_hash[field.id.to_s]
        if field.required
          if val.nil? || val.to_s.strip.empty?
            errs << "#{field.label} is required"
            next
          end
        end
        next if val.nil? || val.to_s.strip.empty?
        case field.field_type
        when 'number'
          errs << "#{field.label} must be a number" unless numeric_string?(val)
        end
      end
      errs
    end

    def surfaced_errors?(errors)
      return false if errors.empty?
      flash.now[:alert] = errors.join(', ')
      true
    end

    def numeric_string?(str)
      /
        ^[+-]? # optional sign
        (?:\d+\.?\d*|\d*\.\d+) # 12, 12.3, .5
        $
      /x.match?(str.to_s)
    end
    def set_form
      @form = if params[:token].present?
                Form.find_by!(public_token: params[:token])
              else
                Form.find(params[:form_id])
              end
    end

    def set_submission
      @submission = @form.submissions.find(params[:id])
    end

    def ensure_owner!
      if @form.user_id.present? && (!user_signed_in? || @form.user_id != current_user.id)
        redirect_to forms_path, alert: 'Only the owner can view submissions.'
      end
    end
end
