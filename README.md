# MokshaCMS

_The MokshaCMS collection of gems provides an integrated system of services for content, event, forum, learning, and newsletter management.  It supports sites with multiple languages and multiple distinct sites per installation.  Administration is built in.  Additional services/engines can be written to provide additional functionality._

- core foundation (core)
- content management (cms)
- event management (event)
- forum management (forum)
- newsletter management (newsletter)

## Installation

For Rails 5, use

`gem 'moksha_cms', git: 'https://github.com/digitalmoksha/moksha_cms.git',  branch: '5-0-stable'`

For Rails 4.2, use

`gem 'moksha_cms', git: 'https://github.com/digitalmoksha/moksha_cms.git',  branch: '4-2-stable'`

If you wish to only use, say, the CMS, then

```
gem 'dm_core',  git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_cms',   git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_admin', git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
```
After running `bundle install`, run the following commands to install the migrations:

```
rake dm_core:install:migrations
rake dm_cms:install:migrations
rake dm_event:install:migrations
rake dm_forum:install:migrations
rake dm_newsletter:install:migrations

```

_Installation instructions are still a work in progress_

## Demo Application

You can grab the [Moksha CMS Demo](https://github.com/digitalmoksha/moksha_cms_demo) for an example of a full application.