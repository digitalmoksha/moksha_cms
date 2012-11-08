!function( $ ) {
  $(function () {
    //===== jQuery file tree =====//

    $('.cms_filetree').fileTree({
            root: 'index',
            script: '/en/admin/cms_pages/1/file_tree',
            expandSpeed: 200,
            collapseSpeed: 200,
            multiFolder: true
        }, function(file) {
            window.location = '/en/admin/cms_pages/' + file;
        }); 
  })
}( window.jQuery );

