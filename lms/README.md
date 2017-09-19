# dm_lms

**dm_lms** provides the learning management system (LMS) for the MokshaCMS collection of gems.  Courses and lessons (multi-lingual) can be created.

_The MokshaCMS collection of gems provides an integrated system of services for content, event, forum, learning, and newsletter management.  It supports sites with multiple languages and mutliple distinct sites per installation.  Administration is built in.  Additional services/engines can be written to provide additional functionality._

- core foundation (core)
- content management (cms)
- event management (event)
- forum management (forum)
- newsletter management (newsletter)

## Installation

Add the following to your Gem file:

```
gem 'dm_preferences',       '~> 1.0'
gem 'dm_core',              git: 'https://github.com/digitalmoksha/dm_core.git', branch: '4-2-stable'
gem 'dm_cms',               git: 'https://github.com/digitalmoksha/dm_cms.git', branch: '4-2-stable'
gem 'dm_lms',               git: 'https://github.com/digitalmoksha/dm_lms.git', branch: '4-2-stable'
gem 'themes_for_rails',     git: 'git://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',           git: 'git://github.com/digitalmoksha/aced_rails.git'
```

After running `bundle install`, run 

```
rake dm_core:install:migrations
rake dm_cms:install:migrations
rake dm_lms:install:migrations
```
