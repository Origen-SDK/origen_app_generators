# This file has been added by origen_app_generators to test that the target can be
# loaded within this application, it will not be included in your final application
# builds once your generator has been released.
namespace :new_app_tests do
  task :load_target do
    Origen.app.target.load!
  end
end
