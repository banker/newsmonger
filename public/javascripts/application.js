// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
var handleReply = function() {
  var replyForm = $('#reply_template').clone();
  replyForm.find('form').attr({id: 'blah'});
  $(replyForm).find('.reply_parent_id').attr({'value': this.id.split('_')[1]});

  $(this).replaceWith(replyForm.html());
}

var upvoteComment = function() {
  var attrs = $(this).attr('id').split('_');
  var votes = parseInt(attrs[1]);
  var id    = attrs[2];
  var story_id = '#story_' + id;
  $(story_id).find('.votes').html((votes + 1) + ' votes');
  $(story_id).find('.upvote').html(' &nbsp;');
  $.post('/comments/' + id + '/upvote');
}

var upvoteStory = function() { 
  var attrs = $(this).attr('id').split('_');
  var votes = parseInt(attrs[1]);
  var id    = attrs[2];
  var story_id = '#story_' + id;
  $(story_id).find('.votes').html((votes + 1) + ' votes');
  $(story_id).find('.upvote').html(' &nbsp;');
  $.post('/stories/' + id + '/upvote');
}

$(document).ready(function() {
  $('.comment_reply').click(handleReply);
  $('.comment_upvote').click(upvoteComment);
  $('.upvote_story').click(upvoteStory);
});
