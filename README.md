[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Origen-SDK/users?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Origen-SDK/origen_app_generators.svg)](https://travis-ci.org/Origen-SDK/origen_app_generators)

# Origen App Generators

New application generators, this basically implements the 'origen new' command.

It is maintained separately from the main Origen core so that improvements and new
application templates can be released independently of the base platform.

This app also provides an API for companies to extend the generic application
templates with their own domain-specific templates.

## Development Considerations

To create a new application generator template run:

~~~text
rake new
~~~

To test run the new app creation process run:

~~~text
rake test
~~~

This will build a new app in the tmp/ directory, when complete you can cd into that dir
and then run 'origen -v' to verify that it can boot.

To run a regression test to make sure that all generators build working apps run:

~~~text
rake regression
~~~

To add a new app generator to the regression list add a new line to TEST_INPUTS in
lib/origen_app_generators.rb.
