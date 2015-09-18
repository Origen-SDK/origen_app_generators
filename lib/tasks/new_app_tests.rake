namespace :new_app_tests do
  desc 'Test that the app and default target can load'
  task :load_target do
    Origen.app.target.load!
  end
end
