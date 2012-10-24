Rails.application.routes.draw do

  mount DmCore::Engine => "/dm_core"
  
  scope ":locale" do

    match '/index', :controller => :home, :action => :index, :as  => :index
  end

  root :to => redirect('/en/index')

end
