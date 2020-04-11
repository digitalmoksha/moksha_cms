Dir[File.dirname(__FILE__) + '/../../lib/dm_event/liquid/filters/*.rb'].sort.each { |file| require file }
Dir[File.dirname(__FILE__) + '/../../lib/dm_event/liquid/tags/*.rb'].sort.each { |file| require file }
