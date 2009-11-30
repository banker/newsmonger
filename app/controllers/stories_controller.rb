class StoriesController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  
  def new
    @story = Story.new
  end

  def index
    @page    = (params[:page] || 1).to_i
    @stories = Story.paginate(:page => @page, :per_page => 15)
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

  # Uses the class method of upvote to fire and forget.
  def upvote
    story_id = Mongo::ObjectID.from_string(params[:id])
    Story.upvote(story_id, current_user.id)
    render :nothing => true
  end
end
