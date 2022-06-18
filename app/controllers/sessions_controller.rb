class SessionsController < ApplicationController
  layout "login", :only => [:new, :index, :destroy, :create]

  def index
    redirect_to (session[:user_id].nil? ? login_url : root_path)
  end

  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      if user.status?
        cookies.signed[:last_activity] = {:value => Time.now + 30.minutes, :expires => 30.minutes.from_now}
        user.login_at = Time.now
        user.save
        session[:user_id] = user.id
        if params[:callback]
          redirect_to params[:callback]
        else
          redirect_to root_url
        end
      else
        flash.now.alert = "Your account has been inactive, Please contact your administrator to active your account."
        render "new"
      end
    else
      flash.now.alert = "Email or Password in invalid!"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

  def is_admin
    true
  end
end