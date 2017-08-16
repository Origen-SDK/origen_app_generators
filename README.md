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


This document outlines the process for creating a new application generator.

### Background

This plugin uses a code generator API from RGen core which itself leans heavily on a 3rd party gem library called
Thor. This gem is used quite widely in the Ruby community for this kind of thing, not least by the code generators
provided by the Ruby on Rails platform.

The code generator API allows the user to do things like:

* Run code to collect user input
* Compile templates to produce dynamic output based on the user's responses
* Copy files verbatim
* Create directories and symlinks
* Delete and inject lines into existing files

Each application type that can be generated by this plugin is an example of a code generator.

The code new application generators are organized into the following hierarchy:

~~~text
RGenAppGenerators::Base
  |
   -> RGenAppGenerators::Application
        |
         -> RGenAppGenerators::Plugin
~~~

**All additional generators within this application must be a subclass of either <code>RGenAppGenerators::Application</code>
or <code>RGenAppGenerators::Plugin</code> depending on whether the end application is intended to be a plugin or not.**

The new application generators should all perform the following functions:

* Prompt the user with some questions to get the new application name and so on
* Create the new application files by either copying or compiling source files and creating
  symlinks or directories as required
* Make any final modifications to the resulting files
* Display any information that the user should know about their new application

#### Generator Execution

When a generator is executed any methods defined in it will be called in the order that they are
defined.
Any methods that are marked as <code>protected</code> will not be called.

For example when the following generator is executed:

~~~ruby
module RGenAppGenerators
  class MyAppGenerator < Application
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

Note that any methods defined by the parent class will get called first. In this application the
parent <code>Application</code> and <code>Plugin</code> classes implement a method to get the user
input that will be common to all applications.

You can disable this behavior if required by re-defining the relevant methods within the child generator class.

#### Source Files

All template or static source files for the generators live in <code>templates/app_generators/</code> and from
there in sub folders based on the name of the particular generator.

All path references to source files made in your generator should be relative to its source file folder, and in
practice what this means is that if you want to refer to the source file of what will become
<code>RGen.root/config/application.rb</code> then you just refer to <code>config/application.rb</code>.

When looking for a particular source file the generator will search in the various source directories
belonging to your generator's parent classes.
For example let's say you make a test engineering generator that has the following class hierarchy:

~~~text
RGenAppGenerators::Base
  |
   -> RGenAppGenerators::Application
        |
         -> RGenAppGenerators::Plugin
              |
               -> RGenAppGenerators::TestEngineering::TestBlock
~~~

Then the following source paths will be searched in this order:

~~~text
templates/app_generators/test_engineering/test_block
templates/app_generators/plugin
templates/app_generators/application
~~~

This means that if you create a file called <code>config/application.rb</code> within
<code>templates/app_generators/test_engineering/test_block</code> then this will override the corresponding
file from the plugin sources and which would itself override the same file from the application sources.

However see the warning in [The Filelist](<%= path "docs/developers/creating#The_Filelist" %>) section below before doing this!

### Creating a New Generator

A rake task is provided to create a new generator, run it as follows:

~~~text
rake new
~~~

### Lean Environment

When the generator is run by a user to generate a new application, it will not run within the scope of an
RGen application.
This means that any references to <code>RGen.app</code> within the generator code are meaningless and will
result in an error.

Furthermore because there is no application there is also no associated gem bundle, so the generator must
be able to run within the lean Ruby environment that is used to boot RGen. In practice what this means is
that you can use any gems that RGen itself relies on (these will be installed in the base Ruby installation),
but you cannot use any others.

The rake tasks provided for testing your new generator will run it within the lean environment, so if it
works there you can be confident that it will also run in production.

### The Filelist

Each generator should return the list of files to be created in the new application via its
<code>filelist</code> method.
If you don't make any changes to this then it will simply inherit the list of files defined
by the generator's parent class.

The filelist is also used to define any directories or symlinks that should be created.
The generator class created by the <code>rake new</code> task contains a commented example of how to add or
remove the various elements from the filelist.

Some application generators may not make any changes to the filelist and will simply augment
the basic application/plugin shell by adding additional code to some of the existing files.

This can be done by either overriding the source file by defining it in the generator's own
source directory, or by [post-modifying](<%= path "docs/developers/creating#Post_Generation_Modifications" %>)
the files after the filelist has been rendered.

<div class="alert">
  <strong>Warning!</strong> While it is tempting (and easier) to simply copy a source file and then
  edit it as required for your target application, this will make your generator harder to maintain as it
  will not automatically pick up changes and improvements to the master templates that will occur over time.
  Therefore it is always preferable to post-modify the file to delete sections or to modify or add additional code
  whenever possible.
</div>

**Note that developers should not add logic to the application/plugin master source files to
implement generator specific output. This approach is not scalable as in the future this plugin
is expected to support many different application types.**

Instead individual generators must either completely override or post-modify the master files
as appropriate.

#### Templates

All files in the file list will be compiled unless explicitly marked with <code>copy: true</code>
or if the destination file name ends in <code>.erb</code>.

ERB markup can be used the same way as in regular RGen templates with the following exceptions:

Whole line Ruby is not enabled (a limitation imposed by Thor), therefore instead of this:

~~~eruby 
<%= "%" %> if x_is_true
Include something
<%= "%" %> end
~~~

You must do:

~~~eruby 
<%= "<" + "% if x_is_true -%" + ">" %>
Include something
<%= "<" + "% end -%" + ">" %>
~~~

Access to variables collected by your generator at runtime is done by assigning them to instance
variables (instead of the options hash used by the RGen compiler).

So for example if you have your user input a product name, then you should assign that to an
instance variable:

~~~ruby
@product_name = get_product_name
~~~

Then in the template:

~~~eruby
The product name is <%= "<" + "%= @product_name %" + ">" %>
~~~

By convention templates in this plugin do not end in <code>.erb</code> and this is reserved
for files that would become <code>.erb</code> files in the end application.

### Post Generation Modifications

It is better to customize any files that are common to all applications
by post modification rather than by completely overriding the entire file.

To do this you have access to the Thor Action methods described here:
[Thor Action API](http://www.rubydoc.info/github/wycats/thor/Thor/Actions)

You can see some examples of these being used in the <code>enable</code> method in
<code>lib/app_generators/new.rb</code> where they are used to add the new generator details
to <code>lib/rgen_app_generators.rb</code>.

As a quick example say you wanted to add a method to <code>config/application.rb</code>, this
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

### Documentation

The rake task will create a documentation file for your new generator in
<code>templates/web/rgen_app_generators/</code> and this should be used to document
any information about the new application shell that your target audience might find useful. 

This page will be automatically linked to from the [RGenAppGenerators Homepage](<%= path "/" %>)
when it is next released.

### Testing the Generator

Rake tasks are provided to test your new generator, to run the <code>rgen new</code> command as
it would appear to your audience run <code>rake test</code>.

Alternatively to skip the first section that selects the required generator you can run
<code>rake 'run[TestEngineering::TestBlock]'</code>, substituting the class name for that of
your new generator.

In both cases the new application will be built in <code>tmp/</code> and you can cd into
that and run it to see if everything works.

### Releasing the Generator

To release the generator simply release a new production version of this plugin, the
<code>rgen new</code> command will automatically check for and run the latest production version
of it every time it is invoked.

