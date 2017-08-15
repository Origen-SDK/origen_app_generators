# The requested command is passed in here as @command
case @command

when "app_gen:test"
  exit 0

when "app_gen:new"
  OrigenAppGenerators::New.start []
  exit 0

# Always leave an else clause to allow control to fall back through to the Origen command handler.
# You probably want to also add the command details to the help shown via 'origen -h',
# you can do this bb adding the required text to @plugin_commands before handing control back to
# Origen.
else
  @plugin_commands << <<-EOT
 app_gen:test Test run the 'origen new' command operation using your latest generators
 app_gen:new  Create a new application or plugin generator
  EOT

end
