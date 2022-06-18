class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  before_action :is_admin, only: [:destroy]

  theme 'admin-theme-v2'

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    if @current_user
      last_activity = cookies.signed[:last_activity] || Time.now - 1.minutes
      unless (last_activity && last_activity > Time.now)
        redirect_to login_url(callback: request.fullpath), alert: "Session Timeout, Login Again..."
      end
    end
    cookies.signed[:last_activity] = {:value => Time.now + 30.minutes, :expires => 30.minutes.from_now}
    # unless @current_user.nil?
    #   session[:last_activity] = session[:last_activity].is_a?(Time) ? session[:last_activity] : Time.now
    #   if (@current_user.login_at + 30.minutes) < Time.now && (session[:last_activity] + 30.minutes) < Time.now
    #     redirect_to login_url + "/?callback=" + request.original_url, alert: "Session Timeout, Login Again..."
    #   end
    # end
    # session[:last_activity] = Time.now
    @current_user
  end

  helper_method :current_user

  def default_url_options(options = {})
    {year: (params[:year].presence || Date.today.year)}
  end

  def authorize
    redirect_to login_url, alert: "Not Authorized" if current_user.nil?
  end

  def is_admin
    redirect_to root_url, notice: "Sorry, Restricted to access these page." unless current_user.administrator?
  end

  def generate_report(report)
    if report.valid?
      @results = report.populate_data
      case report.format
      when "xls"
        headers["Content-Disposition"] = "attachment; filename=\"#{report.filename}.xls\""
        render action: "../reports/xls/#{report.template}.xls.erb", format: "xls"
        return
      else
        if Rails.env.production?
          html = render_to_string(layout: false, action: "../reports/html/#{report.template}.html.erb", formats: [:html], handler: [:erb])
          kit = PDFKit.new(html, orientation: "Landscape")
          kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"
          send_data(kit.to_pdf, filename: "#{report.filename}.pdf", type: "application/pdf", disposition: "inline")
          return
        else
          render "reports/html/#{report.template}"
        end
      end
    end
  end
end