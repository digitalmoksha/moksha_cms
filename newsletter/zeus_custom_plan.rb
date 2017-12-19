# from http://platformonrails.wordpress.com/2013/04/06/smooth-rspec-experience-with-zeus/
#------------------------------------------------------------------------------
require 'zeus/rails'

class CustomPlan < Zeus::Rails

  def spec(argv=ARGV)
    # disable autorun in case the user left it in spec_helper.rb
    RSpec::Core::Runner.disable_autorun!
    exit RSpec::Core::Runner.run(argv.empty? ? ['spec'] : argv)
  end
end

Zeus.plan = CustomPlan.new