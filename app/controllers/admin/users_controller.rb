class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_super_admin!
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = User.order(:id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = :user
    if @user.save
      redirect_to admin_users_path, notice: "User created."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = user_update_params
    # Handle role assignment explicitly and only for valid values
    role_param = params.dig(:user, :role)
    if role_param.present? && current_user&.super_admin? && User.roles.key?(role_param.to_s)
      @user.role = role_param
    end
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end
    if @user.update(attrs)
      redirect_to admin_users_path, notice: "User updated."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself."
    else
      @user.destroy!
      redirect_to admin_users_path, notice: "User deleted."
    end
  end

  private
    def ensure_super_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user&.super_admin?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def user_update_params
      # Do not permit :role for mass assignment; set it explicitly above.
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
