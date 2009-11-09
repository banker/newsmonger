class UsersController < ApplicationController
  layout 'sessions'

  def new
    @user = User.new
    render '/sessions/new'
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      redirect_to root_path
    else
      render '/sessions/new', :layout => 'sessions'
    end
  end
end
