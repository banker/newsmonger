# include this in application controller
module Authentication
  protected
    # Inclusion hook to make #current_user and #signed_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :signed_in?, :authorized? if base.respond_to? :helper_method
    end
    
    # Returns true or false if the user is signed in.
    # Preloads @current_user with the user model if they're signed in.
    def signed_in?
      !!current_user
    end
    
    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (sign_in_from_session || sign_in_from_basic_auth) unless @current_user == false
    end
    
    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end
 
    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    # # only allow nonbobs
    # def authorized?
    # current_user.name != "bob"
    # end
    #
    def authorized?(action=nil, resource=nil, *args)
      signed_in?
    end
 
    # Filter method to enforce a sign_in requirement.
    #
    # To require sign_ins for all actions, use this in your controllers:
    #
    # before_filter :sign_in_required
    #
    # To require sign_ins for specific actions, use this in your controllers:
    #
    # before_filter :sign_in_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    # skip_before_filter :sign_in_required
    #
    def authenticate
      authorized? || access_denied
    end
 
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the sign_in screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action. For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
        # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
        # you may want to change format.any to e.g. format.any(:js, :xml)
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end
 
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
 
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default. Set an appropriately modified
    # after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    # Called from #current_user. First attempt to sign_in by the user id stored in the session.
    def sign_in_from_session
      if session[:user_id]
        self.current_user = User.find_by_id(session[:user_id])
      end
    end
 
    # Called from #current_user. Now, attempt to sign_in by basic authentication information.
    def sign_in_from_basic_auth
      authenticate_with_http_basic do |email, password|
        self.current_user = User.authenticate(email, password)
      end
    end
    
    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on sign_in.
    # However, **all session state variables should be unset here**.
    def sign_out_keeping_session!
      # Kill server-side auth cookie
      @current_user = false # not signed in, and don't do it for me
      session[:user_id] = nil # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end
 
    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (signed-out to signed-in).
    def sign_out_killing_session!
      sign_out_keeping_session!
      reset_session
    end
end
