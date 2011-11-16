# Installing Blacklight 

Please see  [[Prerequisites|Blacklight 2.x PRE REQUISITES]] for pre-requisites Blacklight needs.

Please see [[README_SOLR]] for information about setting up and configuring SOLR ([[http://lucene.apache.org/solr]]).


Note: these instructions apply to releases 2.5.0 and above.
## How to install the Blacklight Demo Application (recommended)

Blacklight uses a new Rails feature called "templates". To install the Blacklight plugin into a new Rails application, run the following command (be sure to answer all of the installation questions):

### Installing Blacklight latest tagged version (recommended):
```
  rails ./blacklight-app -m http://projectblacklight.org/templates/latest.rb 
```
Specific versions are available using  http://projectblacklight.org/templates/[x-y-z].rb

### Installing the "trunk", or master branch:
```
  rails ./blacklight-app -m http://projectblacklight.org/templates/master.rb
```
After the installation process, make note of the instructions for starting Solr and indexing data. Blacklight depends on Solr so be sure it is running.

### Start Solr

The template will give you instructions on how to start Solr, copied here for convenience:
```
  cd jetty
  java -jar start.jar
```
This starts an instance of jetty with Solr running on port 8983. If you want to start on another port, use Java's -D argument:
```
  java -Djetty.port=8888 -jar start.jar
```
Once you start it you can run your Rails app and it will use this SOLR index (expected on port 8983).
```
  ./script/server
```
Now navigate to [[http://localhost:3000]] and you should have a working demo blacklight application with the test data set!
Possible Issues with Gems

Be aware of gems that may have been inadvertently installed in your (home)/.gems directory, rather than in your system location for ruby gems. At least one site encountered difficulties when gems were installed in the account's directory, rather than in the system location. (This can happen if you don't use "sudo gem install" but instead use "gem install"). In this case, you may need to remove the account's version of the gems.

```
  gem uninstall (gem name)   -  note absence of ''sudo''
```
If that doesn't work, you can try the brute force method to remove them:

```
  cd ~/.gem/ruby/1.8/gems
```
then remove everything in that directory.

You may also see messages to run refresh_spec when you run the ’’rake gems’’ command; go ahead and follow those instructions. (In at least one case, the refresh_spec command needed to be run many times before the error messages ceased.)


### Indexing data
The plugin ships with a test data set if you choose to download it during installation.  The installer will optionally index the demo and/or test data for you on installation.  If you did not choose to index the data on installation you can still do so manually. To index this data into the plugin's solr in order to run the plugin's tests run this command:
```
  rake solr:marc:index_test_data RAILS_ENV=test
```
If you would like to have the data indexed for you application level jetty then run this command:
```
  rake solr:marc:index_test_data
```
Note that you can run this command from either the application root or the plugin root.

You should then be able to load [[http://localhost:3000]] in your browser (Rails must be running) and view the test data set working within Blacklight.


## How to install the Blacklight plugin into an existing Rails application
While installing the Blacklight plugin into an existing Rails application is possible, it is not yet as straightforward as installing and building off the demo application. We hope, in the future, to distribute Blacklight as a Rails 3 gem, which will allow for simple installation and easier dependency management.

* Install the Blacklight Rails Engine plugin (e.g. `git submodule add http://github.com/projectblacklight/blacklight.git blacklight` OR `ruby script/plugin install http://github.com/projectblacklight/blacklight.git` )

* Modify your environment.rb to load the engines plugin, e.g.:

```ruby
# Be sure to restart your server when you modify this file
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/blacklight/vendor/plugins/engines/boot')


Rails::Initializer.run do |config|
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/blacklight/vendor/plugins"]
#  [...]
```

* Modify your routes.rb to add Blacklight application routes, e.g.:

```ruby
ActionController::Routing::Routes.draw do |map|
  Blacklight::Routes.build map
# Your application routes
# [...]
end
```

* Install Blacklight configuration:

```bash
cp ./vendor/plugins/blacklight/config/initializers/blacklight_config.rb ./config/initializers
cp ./vendor/plugins/blacklight/config/solr.yml ./config
```

* Install the Blacklight external gem dependencies using `rake gems:install` (or using other appropriate tools).

* Perform the database migrations using `rake db:migrate:all` (you may need to copy ./vendor/plugins/blacklight/vendor/plugins/engines into ./vendor/plugins/engines for Rails to pick up the Engines migration extensions) or by copying the migrations from ./vendor/plugins/blacklight/db/migrate and running the migration normally (e.g. `rake db:migrate`)

* Blacklight provides a customized ApplicationController and ApplicationHelper. If you wish to extend, modify, or incorporate default Blacklight behavior into your custom application, you must modify your local ./app/controller/application_controller.rb and ./app/helpers/application_helper.rb to include these lines, respectively:

```ruby
  require_dependency( 'vendor/plugins/blacklight/app/controllers/application_controller.rb') 
====
  require_dependency( 'vendor/plugins/blacklight/app/helpers/application_helper.rb') 
```

* You now have the Blacklight plugin installed in your Rails application. You still need to setup or configure your Solr instance.
