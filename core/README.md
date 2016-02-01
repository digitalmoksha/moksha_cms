# dm_core

**dm_core** provides the foundation for building an integrated system of services that includes 

- content management ([dm_cms](https://github.com/digitalmoksha/dm_cms))
- event management ([dm_event](https://github.com/digitalmoksha/dm_event))
- forum management ([dm_forum](https://github.com/digitalmoksha/dm_forum))
- learning management ([dm_lms](https://github.com/digitalmoksha/dm_lms))
- newsletter management ([dm_newsletter](https://github.com/digitalmoksha/dm_newsletter))

**dm_core** includes authentication (Devise), role authorization, user profiles, etc.  Common services and features that get used across the system and provide the foundation for the above services.


## Installation

Add the following to your Gem file:

```
gem 'dm_preferences',       '~> 1.0'
gem 'dm_core',              git: 'https://github.com/digitalmoksha/dm_core.git', branch: '4-2-stable'
gem 'themes_for_rails',     git: 'git://github.com/digitalmoksha/themes_for_rails.git'
gem 'aced_rails',           git: 'git://github.com/digitalmoksha/aced_rails.git'
```

After running `bundle install`, run `rake dm_core:install:migrations`
