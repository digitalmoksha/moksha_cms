$(document).ready(function() {

  // When a link is selected in a bootstrap dropdown menu, set the
  // associated text field with the text
  //
  // <button class="btn dropdown-toggle" data-toggle="dropdown" >Folder</button>
  // <ul class="dropdown-menu dropdown-field" data-field="test">
  //   <li><a href="#"><i class="font-heart"></i>Favorite it</a></li>
  // </ul>
  // <input id="test" type="text">
  //----------------------------------------------------------------
  $(".dropdown-field li a").click(function(){
    $("#" + $(this).parent().parent().data("field")).val( $(this).text() )
  });

  //----------------------------------------------------------------
  $('#blog_user_table').dataTable( {
     bJQueryUI: false,
     iDisplayLength: 10,
     bProcessing: false,
     bServerSide: true,
     bStateSave: false,
     aaSorting: [[0, 'asc']],
     sAjaxSource: $('#blog_user_table').data('source')
  });

  // Set the height of the tag reference modal panes, so they scroll like we want
  //----------------------------------------------------------------------
  $('#tag_reference').on('show.bs.modal', function () {
      $('.modal .modal-body .tag_details').css('max-height', $(window).height() * 0.7);
      $('.modal .modal-body .tag_nav').css('max-height', $(window).height() * 0.7);
  });

});
