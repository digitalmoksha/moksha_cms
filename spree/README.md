# dm_spree

**dm_spree** provides the ecommerce management for the MokshaCMS collection of gems.  It is based on an
integrated version of the Spree gem.

_The MokshaCMS collection of gems provides an integrated system of services for content, event, forum, learning, and newsletter management.  It supports sites with multiple languages and multiple distinct sites per installation.  Administration is built in.  Additional services/engines can be written to provide additional functionality._

- core foundation (core)
- content management (cms)
- event management (event)
- forum management (forum)
- newsletter management (newsletter)

## Installation

Add the following to your Gem file:

```
gem 'dm_core',  git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_cms',   git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_admin', git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_event', git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
gem 'dm_spree', git: 'https://github.com/digitalmoksha/moksha_cms.git', branch: '5-0-stable'
```

After running `bundle install`, run 

```
rake dm_core:install:migrations
rake dm_cms:install:migrations
rake dm_event:install:migrations
rake dm_spree:install:migrations
```
