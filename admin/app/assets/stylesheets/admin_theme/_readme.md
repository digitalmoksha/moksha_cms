Our goal is to isolate the bootstrap/fonts/images and theme files from other parts of the system, so they can run with different frameworks and themes.

When updating the bootstrap or theme files, we need to change the path to font and image files, so that the asset pipeline finds the correct versions.

## bootstrap.css

Change the

    @font-face {
      font-family: 'Glyphicons Halflings';

      src: url('../fonts/glyphicons-halflings-regular.eot');
      src: url('../fonts/glyphicons-halflings-regular.eot?#iefix') format('embedded-opentype'), url('../fonts/glyphicons-halflings-regular.woff') format('woff'), url('../fonts/glyphicons-halflings-regular.ttf') format('truetype'), url('../fonts/glyphicons-halflings-regular.svg#glyphicons_halflingsregular') format('svg');
    }

to

    @font-face {
      font-family: 'Glyphicons Halflings';

      src: url('/assets/admin_theme/fonts/glyphicons-halflings-regular.eot');
      src: url('/assets/admin_theme/fonts/glyphicons-halflings-regular.eot?#iefix') format('embedded-opentype'), url('/assets/admin_theme/fonts/glyphicons-halflings-regular.woff') format('woff'), url('/assets/admin_theme/fonts/glyphicons-halflings-regular.ttf') format('truetype'), url('/assets/admin_theme/fonts/glyphicons-halflings-regular.svg#glyphicons_halflingsregular') format('svg');
    }

## icons.css

    @font-face {
    	font-family: 'icomoon';
    	src:url('icons/icons.eot');
    	src:url('icons/icons.eot?#iefix') format('embedded-opentype'),
    		url('icons/icons.woff') format('woff'),
    		url('icons/icons.ttf') format('truetype'),
    		url('icons/icons.svg#icons') format('svg');
    	font-weight: normal;
    	font-style: normal;
    }

to

    @font-face {
    	font-family: 'icomoon';
    	src:url('/assets/admin_theme/icons/icons.eot');
    	src:url('/assets/admin_theme/icons/icons.eot?#iefix') format('embedded-opentype'),
    		url('/assets/admin_theme/icons/icons.woff') format('woff'),
    		url('/assets/admin_theme/icons/icons.ttf') format('truetype'),
    		url('/assets/admin_theme/icons/icons.svg#icons') format('svg');
    	font-weight: normal;
    	font-style: normal;
    }

## sbadmin2-theme.css and styles.css

For images, we override the css in the `custom.css` file - this way we don't have to change each line in the main theme files

## font-awesome.css

Also needs to be updated like above