class UsersController < ApplicationController
  before_filter :authorize
  before_action :is_admin
  # before_filter :check_role, only: [:edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :enable]

  def index
    # @users = User.where(is_deleted: false).order(:username)
    @users = User.where.not(username: "sonnyadmin").order(:username)
    @report = UserReport.new
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    # @user.destroy
    @user.set_deleted
    redirect_to users_url, notice: 'User was successfully deleted.' 
  end

  def enable
    @user.set_enabled
    redirect_to users_url, notice: "User was successfully enabled."
  end

  def report
    @report = UserReport.new(report_params)
    generate_report(@report)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :status, :role)
  end

  def check_role
    unless current_user.administrator?
      redirect_to root_path, notice: "Sorry, Restricted to access these page." unless current_user.id == params[:id].to_i
    end
  end

  def report_params
    params.require(:user_report).permit(:format)
  end
end
