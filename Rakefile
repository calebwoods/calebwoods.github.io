require "rubygems"
require "tmpdir"

require "bundler/setup"
require "jekyll"


# Change your GitHub reponame
GITHUB_REPONAME = 'calebwoods/calebwoods.github.io'
CNAME = 'www.calebwoods.com'


desc "Generate blog files"
task :generate do
  Jekyll::Site.new(Jekyll.configuration({
    "source"      => ".",
    "destination" => "_site"
  })).process
end

desc "Send post data to algolia"
task :algolia do
  system "jekyll algolia push"
end

desc "Generate and publish blog to gh-pages"
task :publish => [:generate, :algolia] do
  Dir.mktmpdir do |tmp|
    cp_r "_site/.", tmp

    pwd = Dir.pwd
    Dir.chdir tmp

    system "echo #{CNAME} > CNAME"

    # Create git repo
    system "git init"
    system "echo 'examples/' > .gitignore"
    system "git add ."
    message = "Site updated at #{Time.now.utc}"
    system "git commit -m #{message.inspect}"
    system "git remote add origin git@github.com:#{GITHUB_REPONAME}.git"
    system "git push origin master --force"

    Dir.chdir pwd
  end
end
