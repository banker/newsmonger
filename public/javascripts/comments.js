var Comment = function() {
  initialize: function() {

  }
}

<table>
  <form action="http://localhost:3000/comments" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="0Ic8uTHWZjng4HGBFu7ajWlFuMsRRylC2UX2np1kw4I=" /></div>
    <input type="hidden" name="comment[story_id]" value="4af8347f3632310000000001" />
    <input type="hidden" name="comment[parent_id]" value="" />
  <fieldset>
  <ol>
    <li>

      <label for="comment">Comment</label>
      <textarea rows="7" cols="40" name="comment[body]"></textarea>
    </li>
    <li>
      <input type="submit" value="Submit" /> 
    </li>
   </ol> 
  </fieldset>
  </form>
</table>
  
