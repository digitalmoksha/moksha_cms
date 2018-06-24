Rails.backtrace_cleaner.remove_silencers!
Rails.backtrace_cleaner.add_silencer { |line| line !~ DmCore::APP_DIRS_PATTERN }

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /actionpack/ }
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /activesupport/ }
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /actionview/ }
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /railties/ }
