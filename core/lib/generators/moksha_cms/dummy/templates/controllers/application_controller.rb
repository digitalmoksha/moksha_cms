class ApplicationController < DmCore::ApplicationController
  protect_from_forgery with: :exception
end
