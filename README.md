# ccng-routes

**An api routes print tool for Cloud Foundry CCng (cloud_controller_ng)**

The Cloud Foundry CCng (cloud_controller_ng) component generates its API routes dynamically. This tool prints the generated routes in Ruby-on-Rails "rake routes" style.

## Example

[Routes for CCng API v2.79.0](https://gist.github.com/nota-ja/d6a29229f21b863ba643ca584ef9e5e3)

## Prerequisites

- git
- ruby
- bundler gem


## Usage

### Simple

- Clone this repository
```
git clone https://github.com/nota-ja/ccng-routes.git
```
- Change directory to the cloned repository and run ccng-routes.sh
```
cd ccng-routes
./ccng-routes.sh
```

### Advanced

You may specify a revision to generate api routes.
```
CCNG_REV=a_git_revision ./ccng-routes.sh
```

Additionally, You may use an exsiting cloud_controller_ng repository.
```
CCNG_REPO=path/to/cloud_controller_ng ./ccng-routes.sh
```
As the details described below, this tool touches the targetted cloud_controller_ng repository.

So it is recommended to use a newly cloned repository.

The script ccng-routes.sh clones the cloud_controller_ng repository to directly under this tool's directory and use it if the environment variable CCNG_REPO is not given.

The routes info is printed to stderr. So if you want to write routes info alone to a file, just do like:
```
CCNG_REPO=path/to/cloud_controller_ng CCNG_REV=a_git_revision ./ccng-routes.sh 2> routes.txt
```


## Details

The ccng-routes.sh script is based on 'routes' task in the Rakefile. You can run the task independently as:
```
BUNDLE_GEMFILE=path/to/cloud_controller_ng/Gemfile bundle exec rake routes
```
Because the task reuses gems used in cloud_controller_ng, BUNDLE_GEMFILE environment variable must be specified properly.

The rake task also accepts CCNG_REPO environment variable described above.

The task actually does following operations:

1. (preparation) 
  1. Use CCNG_REPO environment variable as cloud_controller_ng repo. If not defined, $PWD/cloud_controller_ng is set.
  2. Clone cloud_controller_ng repo if not exist.
2. Apply the patch (routes.rb.patch), that adds printing facility into dynamic route generation process, to lib/cloud_controller/rest_controller/routes.rb in cloud_controller_ng repo.
3. Execute the route-defining code by requiring lib/cloud_controller.rb in cloud_controller_ng repo.
4. Unpatch the patch applied.

When you want to get CCng routes of a specific revision with the rake task, just cd to the cloud_controller_ng repo, checkout the revision, sync / update its submodule, run bundle install to install gems, then back to this tool's directory and run the rake task.
```
pushd path/to/cloud_controller_ng
git checkout a_git_revision
git submodule sync; git	submodule update --init	--recursive
bundle install --path vendor/bundle
popd
CCNG_REPO=path/to/cloud_controller_ng BUNDLE_GEMFILE=path/to/cloud_controller_ng/Gemfile bundle exec rake routes
```

As a matter of fact, the ccng-routes.sh script executes the process described above.


## Tips

### Post production

A generated route may contain an ID of Proc object and a path to the cloud_controller_ng repo when the action part of the route is defines as a Proc object. It's not convenient to compare two sets of API routes of different revisions and / or in different paths.

I am using the following script to remove those extra information:
```
cat routes.txt | perl -lane 's/Proc:0x[0-9a-f]+@.+\/cloud_controller_ng\//Proc:\@/; print $_' | sort > marshalled.routes.txt
```
(Assume routes.txt is a set of generated routes)

If you make another marshalled set of routes, then you can compare the two route sets.


## Known Issue(s)

Sometimes rake may fail because of version unmatch of nokogiri's dynamically compiled library.
```
rake aborted!
dlopen(cloud_controller_ng/vendor/bundle/ruby/1.9.1/gems/nokogiri-1.6.1/lib/nokogiri/nokogiri.bundle, 9): Library not loaded: cloud_controller_ng/vendor/bundle/ruby/1.9.1/gems/nokogiri-1.6.1/ports/x86_64-apple-darwin13.3.0/libxml2/2.8.0/lib/libxml2.2.dylib
```
A workaround is:
```
pushd $CCNG_REPO
rm vendor/bundle/ruby/1.9.1/specifications/nokogiri-1.6.1.gemspec
rm -rf vendor/bundle/ruby/1.9.1/gems/nokogiri-1.6.1/
bundle install --path vendor/bundle
popd
```
