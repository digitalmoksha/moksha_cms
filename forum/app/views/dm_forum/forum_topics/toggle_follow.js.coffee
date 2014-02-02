$("#follow_button").toggleClass('follow_active')
if $("#follow_button").hasClass('follow_active')
  $('#follow_button').val('Stop Following')
else
  $('#follow_button').val('Follow')
