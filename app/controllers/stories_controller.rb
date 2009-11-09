class StoriesController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  
  def new
    @story = Story.new
  end

  def index
    @page    = (params[:page] || 1).to_i
    @stories = Story.paginate(:page => @page, :per_page => 2)
  end

  def show
    @story    = Story.find_by_slug(params[:id])
    @comments = Comment.threaded_with_field(@story)
  end

  def create
    @story = Story.new(params[:story])
    @story.user = current_user
    if @story.save
      redirect_to root_url
    else
      render :action => :new
    end
  end

  def upvote
    @story = Story.find(params[:id])
    @story.upvote(current_user)
    render :nothing => true
  end
end
