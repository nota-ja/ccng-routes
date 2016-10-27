ccng_repo = File.expand_path(ENV["CCNG_REPO"])
ccng_patch = File.expand_path("../routes.rb.patch", __FILE__)

require "rubygems"
require "bundler/setup"

$:.unshift(File.join(ccng_repo, "lib"))
$:.unshift(File.join(ccng_repo, "app"))
$:.unshift(File.join(ccng_repo, "middleware"))

task :routes do
  Dir.chdir(ccng_repo) do
    begin
      system("git apply #{ccng_patch}")
      require "cloud_controller"
    ensure
      system("git apply --reverse #{ccng_patch}")
    end
  end
end
