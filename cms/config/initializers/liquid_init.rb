Dir[File.dirname(__FILE__) + '/../../lib/dm_cms/liquid/filters/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/../../lib/dm_cms/liquid/tags/*.rb'].sort.each { |file| require file }
