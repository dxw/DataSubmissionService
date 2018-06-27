class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :ensure_user_signed_in

  private

  def current_user
    @_current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def ensure_user_signed_in
    redirect_to root_path unless current_user
  end
end
