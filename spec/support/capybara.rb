RSpec.configure do |config|
     config.before(:each, type: :system) do
          if ENV["DRIVER"] == "selenium"
               driven_by(:selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ])
          else
               driven_by(:rack_test)
          end
     end
end
