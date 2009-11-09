
require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  context "a root-level comment:" do 
    setup do 
      @story    = Factory(:story)
      @comment  = Factory(:comment, :story => @story)
    end

    should "belong to the story" do 
      story = Story.find(@story.id)
      assert_equal 1, story.comments.size
      assert_equal @comment.id, story.comments.first.id
    end

    should "add one to the story's comment cache" do 
      @story = Story.find(@story.id)
      assert_equal 1, @story.comment_count
    end

    should "have a blank path" do 
      assert_equal "", @comment.path
    end

    should "have just one vote" do 
      assert_equal 1, @comment.votes 
    end

    should "have a vote from the user who created the comment" do 
      assert @comment.voters.include?(@comment.user.id)
    end

    should "have root set to true" do 
      assert @comment.root?
    end

    context "with its reply: " do 
      setup do 
        @reply_user = Factory(:user)
        @reply = Comment.new(:parent_id => @comment.id, :user => @reply_user, :body => "Reply")
        @story.comments << @reply
        @story.save
      end

      should "have the specified user" do 
        assert_equal @reply_user, @reply.user
      end

      should "have a path equal to parent id" do 
        assert_equal ":" + @comment.id, @reply.path
      end

      should "have one vote" do 
        assert_equal 1, @reply.votes
      end

      should "have root set to false" do 
        assert !@reply.root?
      end

      context "with a second reply: " do 
        setup do 
          @ru  = Factory(:user)
          @rep = Comment.new(:parent_id => @reply.id, :user => @ru, :body => "Another reply")
          @story.comments << @rep
          @story.save
        end

        should "have a path containing the parent's id" do 
          assert_equal @reply.path + ":" + @reply.id, @rep.path
        end

        should "have a depth of 2" do 
          assert_equal 2, @rep.depth
        end
      end
    end
  end

  context "many nested comments" do 
    setup do 
      @story   = Factory(:story)
      @ten     = Factory(:comment, :body => "ten",    :votes => 600, :story_id => @story.id)
      @a       = Factory(:comment, :body => "a",      :votes => 2000, :story_id => @story.id)
      @one     = Factory(:comment, :body => "one",    :votes => 5, :story_id => @story.id)
      @two     = Factory(:comment, :body => "two",    :parent_id => @one.id)
      @b       = Factory(:comment, :body => "b",      :parent_id => @a.id, :votes => 5)
      @three   = Factory(:comment, :body => "three",  :parent_id => @one.id, :votes => 15)
      @c       = Factory(:comment, :body => "c",      :parent_id => @a.id, :votes => 50)
      @twenty  = Factory(:comment, :body => "twenty", :votes => 5, :parent_id => @ten.id)
      @thirty  = Factory(:comment, :body => "thirty", :parent_id => @ten.id, :votes => 400)
      @forty   = Factory(:comment, :body => "forty",  :parent_id => @thirty.id, :votes => 23)
      @fifty   = Factory(:comment, :body => "fifty",  :parent_id => @twenty.id, :votes => 2)
    end

    should "display in vote/thread order" do
      @comments = Comment.threaded_with_field(@story, 'votes')
      assert_equal [@a, @c, @b, @ten, @thirty, @forty, @twenty, @fifty, @one, @three, @two], @comments
    end
  end
end
