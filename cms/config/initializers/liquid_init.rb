# require each tag -- registration is done in the tag file itself, so they can't be autoloaded
Dir.glob(File.expand_path('../../../app/liquid/tags/*.rb', __FILE__)).sort.each do |path|
  require path
end

Dir.glob(File.expand_path('../../../app/liquid/filters/*.rb', __FILE__)).sort.each do |path|
  require path
end
