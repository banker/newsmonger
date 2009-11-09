class SessionsController < ApplicationController
  skip_before_filter :store_location
  
  layout 'sessions'

  def new
    sign_out_keeping_session!
    @user = User.new
    render 'new'
  end

  def create
    @user = User.new
    sign_out_keeping_session!
    if @user = User.authenticate(params[:email], params[:password])
      session[:user_id] = @user.id
      redirect_back_or_default root_url
    else
      redirect_to :action => :new
    end
  end

  def destroy
    sign_out_killing_session!
    redirect_to new_session_url
  end
end

