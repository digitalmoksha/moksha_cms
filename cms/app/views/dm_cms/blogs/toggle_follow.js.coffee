$("#follow_button").toggleClass('follow_active')
if $("#follow_button").hasClass('follow_active')
  $('#follow_button').val('<%= I18n.t('fms.follow_stop') %>')
else
  $('#follow_button').val('<%= I18n.t('fms.follow') %>')
