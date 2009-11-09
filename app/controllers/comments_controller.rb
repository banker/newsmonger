class CommentsController < ApplicationController
  before_filter :login_required, :except => :index
  skip_before_filter :verify_authenticity_token

  def index
    @comments = Comment.find
  end

  def create
    @story   = Story.find(params[:comment][:story_id])
    @comment = Comment.new(params[:comment].merge(:user => current_user))
    @comment.save
    redirect_to story_url(@story)
  end

  def upvote
    @story = Story.find(params[:id])
    @story.upvote(current_user)
    render :nothing => true
  end
end
