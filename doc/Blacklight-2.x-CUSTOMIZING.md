# Customizing Blacklight (2.x)

There are lots of way to override specific behaviors and views in Blacklight. One of the most important things though is to not change the blacklight source files unless you really know what you're doing. The problem with overriding sources files is that when you update your blacklight plugin, your changes will be lost! In short, stay away from making changes here:
  `vendor/plugins/blacklight`

If you find that there is no other way to make your customization, please describe your problem on the [[mailing list|http://groups.google.com/group/blacklight-development]] -- we'll do the best we can to help out, and even make changes to Blacklight as needed.



## Overriding Views (templates and partials)
As a Rails Engine, you can easily override views in your app. To see what views are available, look here:
  `vendor/plugins/blacklight/app/views/`

Once you find the view you'd like to change, copy the source code from the plugin view (optional) into a new file, with the same name and path in your own app/views directory.

It's best to over-ride as little as possible, to maximize your forward compatibility. Either a pretty small focused partial template; or a larger template which itself mostly calls out to helper functions or partial templates, so your over-ridden version can call out to those same helpers or partial templates housed in blacklight core code. 

## Overriding Controllers

1. Find the controller you're interested in in blacklight's app/controllers/  . 
2. Create a file with the same name in your local app/controllers. 
3. This file requires the original class, and then re-opens it to add more methods. 
```ruby
require_dependency('vendor/plugins/blacklight/app/controllers/some_controller.rb')

class SomeController < ApplicationController
   # custom code goes here
end
```
In that "custom code goes here", you can redefine certain methods (action methods or otherwise) to do something different.  You can also add new methods (again action methods or otherwise), etc. 

It's kind of hard to call 'super' to call original functionality: 
* the ruby language features here make 'super' unavailable, although you can work around that confusingly with the rails #alias_method_chain method. 
* but more importantly, action methods in particular don't really suit themselves to being over-ridden and called by super, because the original implementation often does something you'd want to change but there's no easy way to 'undo' -- calling 'render', which can only be called once. 

So basically, if you find yourself wanting to access some functionaltiy in the original implementation of a method that you also want to over-ride -- the best solution is probably to refactor Blacklight core code to put that functionality in a subsidiary method, so you can over-ride the action method entirely but call that logic from core.  Action methods should be short and sweet anyway. 


## Custom View Helpers
One of the most common things you might need to is create a view helper. Blacklight comes packaged with several view helper modules, each corresponding to a specific controller. To override an existing helper method, You simply create a new helper file with the same name and path as the existing blacklight helper. You then add the module code. For example, the main layout view calls a helper named "application_name". The value of this is put into the HTML document's title tag. If you'd like to customize this:

1. create a new file here: app/helpers/application_helper.rb
2. bring in the existing application helper code by adding this line:
```ruby
      require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
```
3. "re-open" the ApplicationHelper module by adding this to the file:
```ruby
      module ApplicationHelper
      
      end
```
4. add the application_name method to the module:
```ruby
      def application_name
        'my new application name'
      end
```

You'll end up with something like this, in your app/helpers/application_helper.rb file:
```ruby
  require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
  module ApplicationHelper
    def application_name
      'my new application name'
    end
  end
```
## Adding in your own CSS or Javascript

You probably already have a local `app/controllers/application_controller.rb`.  If you don't, create one that looks like this:
```ruby

    require_dependency('vendor/plugins/blacklight/app/controllers/application_controller.rb')

    class ApplicationController < ActionController::Base

    end
```

Now create a css file called whatever you want in your own public/stylesheets. Say public/stylesheets/my_css.css . And/or a JS file, say public/stylesheets/my_js.js

inside the class definition, add like so:
```ruby
    class ApplicationController < ActionController::Base
        before_filter :add_my_own_assets

        protected
        def add_my_own_assets
            stylesheet_links << "my_css"
            javascript_includes << "my_js"
        end
    end
```