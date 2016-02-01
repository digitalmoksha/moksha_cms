# dm_cms

**dm_cms** provides the content management system (CMS) for the MokshaCMS collection of gems.  A particular site can have multiple, configurable languages, and are integrated into the content editor.  Content can be either Markdown, Textile, or raw HTML.  Multi-lingual snippets of content can be defined and placed in other content when needed.

_The MokshaCMS collection of gems provides an integrated system of services for content, event, forum, learning, and newsletter management.  It supports sites with multiple languages and mutliple distinct sites per installation.  Administration is built in.  Additional services/engines can be written to provide additional functionality._

- core foundation ([dm_core](https://github.com/digitalmoksha/dm_core))
- content management ([dm_cms](https://github.com/digitalmoksha/dm_cms))
- event management ([dm_event](https://github.com/digitalmoksha/dm_event))
- forum management ([dm_forum](https://github.com/digitalmoksha/dm_forum))
- learning management ([dm_lms](https://github.com/digitalmoksha/dm_lms))
- newsletter management ([dm_newsletter](https://github.com/digitalmoksha/dm_newsletter))

## Installation

Add the following to your Gem file:

```
gem 'dm_preferences',       '~> 1.0'
gem 'dm_core',              git: 'https://github.com/digitalmoksha/dm_core.git', branch: '4-2-stable'
gem 'dm_cms',               git: 'https://github.com/digitalmoksha/dm_cms.git', branch: '4-2-stable'
gem 'themes_for_rails',     git: 'git://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',           git: 'git://github.com/digitalmoksha/aced_rails.git'
```

After running `bundle install`, run 

```
rake dm_core:install:migrations
rake dm_cms:install:migrations
```
