Steps for Creating a New Site
=============================

- On server, run `rake dm_core:create_account`


Asset Layout
============

Since we support multiple sites per installation, we need a good way to keep the assets, themes, etc, walled off from each other.

Although we use the "theme_for_rails" gem, each site only supports one "theme" - we use the theme name to allow us to indicate which site we're accessing.  The theme name is built from the account prefix.  For example, for "domain.net", if the account prefix is "domnet", then that is also the theme name.

A sites assets consist of many type of files - images, stylesheets, views, layouts, locales, etc.  Specific theme assets (views, layouts, locales, code/tags, etc) live in the `{rails_root}/themes` folder.  When possible, these assets will be inserted/compiled into the Rails asset pipeline.  In addition, protected assets, which require a login to access, are also stored here.

{rails_root}
  - themes
    - {theme_name}
      - _theme.yml                  : theme specification file
      - protected_assets            : assets that require login
      - theme_assets                : assets specific to this theme, and are inserted into asset pipeline
        - {theme_name}
          - images                  : images for the theme
          - javascripts             : javascripts for the theme
          - stylesheets             : stylesheets for the theme
      - theme_support
        - locales                   : internationlization files
        - tags                      : liquid tags specific for this theme
        - views                     : custom views for this theme

Public assets, such as uploaded images and videos, reside in the public folder.  A url might look like: `/site_assets/{theme_name}/site/image/logo.jpg`

{rails_root}
  - site_assets
    - {theme_name}
      - site
        - audio
        - images
        - library
        - newsletter
        - videos

Typically, these assets are stored in a repository, such as subversion or git, to allow the site owner to have access to those files to make changes, and to provide an easy way to deploy.  The capistrano deploy would pull all assets into the shared directory, and then symlink the various pieces to their correct location.  The recommended layout for a domain in the repository:

{repository_root}
  - {domain_name}
    - site_assets
      - {theme_name}
        - _theme.yml                  : theme specification file
        - protected_assets            : assets that require login
        - theme_assets                : assets specific to this theme, and are inserted into asset pipeline
          - {theme_name}
            - images                  : images for the theme
            - javascripts             : javascripts for the theme
            - stylesheets             : stylesheets for the theme
        - theme_support
          - locales                   : internationalization files
          - tags                      : liquid tags specific for this theme
          - views                     : custom views for this theme
      - site
        - audio
        - images
        - library
        - newsletter
        - videos
