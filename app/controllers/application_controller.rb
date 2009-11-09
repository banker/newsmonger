# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery 
   
  before_filter :store_location

  filter_parameter_logging :password
  
  protected

  def login_required
    if !current_user
      flash[:notice] = "Please log in."
      redirect_to signin_url
    else
      return true
    end
  end
end
