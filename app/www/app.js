$(document).ready(function(){
  isVisibleDamage = true;
  $('#toggle_credits').click(function(){
    $('#credits_box').slideToggle('slow');
     if(isVisibleDamage){
	   	$('#toggle_credits').html("Hide");
		    isVisibleDamage = false;
	    } else {
		    $('#toggle_credits').html("Credits");
		    isVisibleDamage = true;
	    }
  })
});