[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Origen-SDK/users?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Origen-SDK/origen_app_generators.svg)](https://travis-ci.org/Origen-SDK/origen_app_generators)

# Origen App Generators

This plugin implements all of the starter applications that can be generated from the `origen new` command.
It is maintained separately from Origen core so that improvements and new
application templates can be released independently of the base platform.

Additionally, it provides infrastructure and APIs to allow companies to create their own version
of this plugin, allowing them to create their own customized starter application templates and then 
make them available to their users via `origen new`.

To extend `origen new` with your own custom application generators,
run `origen new` and create your own version of this plugin by selecting the following options:

* 1 - Origen Infrastructure
  * 0 - A plugin to make your own application templates available through the 'origen new' command
  
To hook your plugin into the `origen new` command, either release it to your private gem server, check it into your
Git server, or copy it to a central location that is accessible to all of your users.
Then update the [app_generators](https://github.com/Origen-SDK/origen/blob/master/origen_site_config.yml#L7) attribute within your
[site_config file](http://origen-sdk.org/origen/guides/starting/company/) to point to wherever you have put it.

If you don't see it straight away, run `origen new` with the `--fetch` option to force it to
fetch the latest versions of the generators.

The notes that follow apply to both the origen_app_generators plugin and any company-specific
generator plugins.

## Quickstart

To create a new application generator run the following command:

~~~text
origen app_gen:new
~~~

This will create a new generator within the `lib` directory and then update the top-level file in the `lib` directory
to properly hook it into the `origen new` system.
By default, this new generator will create the same empty application or plugin starter that you would get from
selecting option 0 in the `origen new` command.

You can test run your new generator by running the following command:

~~~text
origen app_gen:test
~~~

This will build a new app in the application's `tmp` directory, and when complete you can cd into that directory
and run `origen -v` to verify that it can boot. At this point you can further interact with the application in the
normal way to test out anything else.

During the creation of a new generator, you will likely repeat this many times as you go through the process of modifying the
generator and then observing the new output. To make this easier, a system is built in that allows you to automate the
answers to the questions that are given to the user when creating a new application.

Within the top-level lib file you will see a set of test inputs something like this:

~~~ruby
TEST_INPUTS = [
  # 0 - TestEngineering::MicroTestBlock
  ['1', '0', :default, :default, 'A cool plugin', 'yes', :default]
] # END_OF_TEST_INPUTS Don't remove this comment, it is used by the app_gen:new command!
~~~

The last item in the array will be a starter set of inputs that has been created for the new genrator that was just added.
To test the new generator with these inputs supply the `-i` option and supply the index number of the set of inputs you
wish to apply:

~~~text
origen app_gen:test -i 0
~~~
Modify the inputs as required as you further develop the generator, making sure to add a value for any additional questions
that you add. The `:default` keyword can be used for any questions which have a default option that you wish to select, this
is equivalent to just pressing return in response to the given question.

In all cases an additional argument must be supplied at the end, this tells the test command about any commands that you want
to run within the generated application to test it.
Supplying the `:default` keyword for this argument will execute the following tests:

* origen -v
* origen lint --no-correct
* Test that the default target loads cleanly
* origen web compile --no-serve

If you want to run no tests, set this final argument to `nil`.

Alternatively you can specify your own set of operations by supplying an array of commands:

~~~ruby
['1', '0', :default, :default, 'A cool plugin', 'yes', ['origen -v', 'origen g my_pattern']]
~~~

Within the array of custom commands you can also supply the `:default` and `:load_target` keywords to execute the default
set of tests or the load target test respectively, for example:

~~~ruby
['1', '0', :default, :default, 'A cool plugin', 'yes', [:default, 'origen g my_pattern']]
~~~

To run a regression test which will execute all sets of test inputs, run:

~~~text
origen app_gen:test -r
~~~

You should find the generator file itself (the one created for you in a sub-folder of the `lib` directory) well commented
and with pointers towards examples from existing generators.

Once you are happy with your new generator release your application generators plugin in the normal way. The version of the
generators picked up by the `origen new` command is automatically refreshed on a per-user basis every 24 hours, or if you
need access to it immediately run `origen new` with the `--fetch` option to force it.

There now follows a more detailed guide on how to create the generator itself.

## Notes on Creating Generators

The application generators use a code generator API from Origen core which itself leans heavily on a 3rd party gem library called
Thor. This gem is used quite widely in the Ruby community for this kind of thing, not least by the code generators
provided by the Ruby on Rails web application platform.

The code generator API allows the user to do things like:

* Run code to collect user input
* Compile templates to produce dynamic output based on the user's responses
* Copy files verbatim
* Create directories and symlinks
* Delete and inject lines into existing files

Each application type that can be generated by this plugin is an example of a code generator.

The code new application generators are organized into the following hierarchy:

~~~text
OrigenAppGenerators::Base
  |
   -> OrigenAppGenerators::Application
        |
         -> MyAppGenerators::Application
        |
         -> OrigenAppGenerators::Plugin
              |
              -> MyAppGenerators::Plugin
~~~

**All generators must be a subclass of either `OrigenAppGenerators::Application`
or `OrigenAppGenerators::Plugin` depending on whether the end application is intended to be a plugin or not.**

The new application generators should all perform the following functions:

* Prompt the user with some questions to get the new application name and so on
* Create the new application files by either copying or compiling source files and creating
  symlinks or directories as required
* Make any final modifications to the resulting files
* Display any information that the user should know about their new application

### Generator Execution

When a generator is executed any methods defined in it will be called in the order that they are
defined.
Any methods that are marked as `protected` will not be called.

For example when the following generator is executed:

~~~ruby
module MyAppGenerators
  class MyGenerator < Application
    def say_hello
      puts "Hello" 
    end

    def call_a_helper
      puts "About to call"
      a_helper_method
      puts "Returned from call"
    end

    protected

    def a_helper_method
      puts "Helper method called!"
    end

    def this_does_nothing
      puts "Another method called!"
    end
  end
end
~~~

Then you would see this:

~~~text
Hello
About to call
Helper method called!
Returned from call
~~~

Note that any methods defined by the parent classes will get called first. The
parent `OrigenAppGenerators::Application` and `OrigenAppGenerators::Plugin` classes implement methods to get the user
input that will be common to all applications.

You can disable this behavior if required by re-defining the relevant methods within the child generator class.

### Source Files

All template or static source files for the generators live in `templates/app_generators` and from
there in sub folders based on the name of the particular generator.

All path references to source files made in your generator should be relative to its source file folder, and in
practice what this means is that if you want to refer to the source file of what will become
`Origen.root/config/application.rb` then you just refer to `config/application.rb`.

When looking for a particular source file the generator will search in the various source directories
belonging to your generator's parent classes.
For example let's say you make a test engineering generator that has the following class hierarchy:

~~~text
OrigenAppGenerators::Base
  |
   -> OrigenAppGenerators::Application
        |
         -> OrigenAppGenerators::Plugin
              |
               -> MyAppGenerators::Plugin
                    |
                     -> TestEngineering::TestBlock
~~~

Then the following source paths will be searched in this order:

~~~text
<my_app_generators>/templates/app_generators/test_engineering/test_block
<my_app_generators>/templates/app_generators/plugin
<origen_app_generators>/templates/app_generators/plugin
<origen_app_generators>/templates/app_generators/application
~~~

This means that if you create a file called `config/application.rb` within
`<my_app_generators>/templates/app_generators/test_engineering/test_block` then this will override the corresponding
file from origen_app_generators.

However see the warning in *The Filelist* section below before doing this!

### Lean Environment

When the generator is run by a user to generate a new application, it will not run within the scope of an
Origen application.
This means that any references to `Origen.app` within the generator code are meaningless and will
result in an error.

Furthermore, because there is no application there is also no associated gem bundle, so the generator must
be able to run within the lean Ruby environment that is used to boot Origen. In practice what this means is
that you can use any gems that Origen itself relies on (these will be installed in the base Ruby installation),
but you cannot use any others.

The `origen app_gen:test` command that is provided for testing the generators will run them within the lean environment, so if it
works there you can be confident that it will also run in production.

### The Filelist

Each generator should return the list of files to be created in the new application via its
`filelist` method.
If you don't make any changes to this then it will simply inherit the list of files defined
by the generator's parent class.

The filelist is also used to define any directories or symlinks that should be created.
The generator class created by the `origen app_gen:new` command contains a commented example of how to add or
remove the various elements from the filelist.

Some application generators may not make any changes to the filelist and will simply augment
the basic application/plugin shell by adding additional code to some of the existing files.

This can be done by either overriding the source file by defining it in the generator's own
source directory, or by post-modifying the files after the filelist has been rendered as described further
down.


**Warning!** While it is tempting (and easier) to simply copy a source file and then
edit it as required for your target application, this will make your generator harder to maintain as it
will not automatically pick up changes and improvements to the master templates that will occur over time.
Therefore it is always preferable to post-modify the file to delete sections or to modify or add additional code
whenever possible.

**Note that developers should not add logic to the application/plugin master source files to
implement generator specific output. This approach is not scalable as in the future this plugin
is expected to support many different application types.**

Instead, individual generators must either completely override or post-modify the master files
as appropriate.

#### Templates

All files in the file list will be compiled unless explicitly marked with `copy: true`
or if the destination file name ends in `.erb`.

ERB markup can be used the same way as in regular Origen templates with the following exceptions:

Whole line Ruby is not enabled (a limitation imposed by Thor), therefore instead of this:

~~~eruby 
% if x_is_true
Include something
% end
~~~

You must do:

~~~eruby 
<% if x_is_true -%>
Include something
<% end -%>
~~~

Access to variables collected by your generator at runtime is done by assigning them to instance
variables (instead of the options hash used by the Origen compiler).

So for example if you have your user input a product name, then you should assign that to an
instance variable:

~~~ruby
@product_name = get_product_name
~~~

Then in the template:

~~~eruby
The product name is <%= @product_name %>
~~~

By convention, templates in this plugin do not end in `.erb` and this is reserved
for files that would become `.erb` files in the end application.

### Post Generation Modifications

It is better to customize any files that are common to all applications
by post modification rather than by completely overriding the entire file.

To do this you have access to the Thor Action methods described here:
[Thor Action API](http://www.rubydoc.info/github/wycats/thor/Thor/Actions)

You can see some examples of these being used in the `enable` method in
`lib/app_generators/new.rb` where they are used to add the new generator details
to `lib/origen_app_generators.rb`.

As a quick example say you wanted to add a method to `config/application.rb`, this
could be achieved by injecting it at the end of the class like this:

~~~ruby
# Always ensure the filelist has been rendered first
def generate_files
  build_filelist 
end

# Add a custom domain method to config/application.rb
def add_method_to_application
  # Define a regular expression to define a point in the file where you want to inject, in this
  # case the 'end' of the class definition (the only 'end' that occurs at the beginning of a line)
  end_of_class = /^end/
  # Define the code snippet
  code = <<-END
  def some_domain_specific_method
    do_something
  end  
  END
  # Now inject it
  inject_into_file "config/application.rb", code, before: end_of_class
end
~~~
