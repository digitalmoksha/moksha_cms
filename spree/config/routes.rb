DmSpree::Engine.routes.draw do

  scope ":locale" do
    mount Spree::Core::Engine, at: '/spree'
  end

end
