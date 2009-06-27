You can follow most of Ari's instructions on installing ClockingIT
http://wiki.clockingit.com/wiki:source but get my branch.

I'm using JRuby 1.3, http://jruby.codehaus.org/

If you have a working database, you should be able to run the code without running setup.rb, but if you need a new database, you need to use Ruby, not JRuby do run setup.rb

After running setup.rb, or even you did not, modify database.yml to use "adapter: jdbcmysql", see ./config/database.yml-jruby-example

At this stage, I'm still having trouble with 'rake gems', you may need to just start the app, and see what's missing.

I'm using NetBeans 6.5.1 Ruby version for development.  It's a smaller install than taking the full Java or J2EE version.  If you use NetBeans, I can help with that.  You certainly want to ensure that caching is off so that you can take advantage of NetBeans debugging and changing code on the fly.

Now for Solr / acts_as_solr
http://github.com/mattmatt/acts_as_solr/tree/master

Using Ruby again... do 
ruby script/plugin install git://github.com/mattmatt/acts_as_solr.git

Using *J*Ruby start Solr
JRuby does not allow fork() by default, so rather than the simple rake you could do, since rake is on your JRuby path you need to pass rake some options:

    rake -J-Djruby.fork.enabled=true solr:start

I thought that would work, but not for me, so I just modified the rake file itself.
./clockingit/vendor/plugins/acts_as_solr/lib/tasks/solr.rake
diff of old and new solr.rake files... just remove the fork()
20c20
<          # pid = fork do
---
>          pid = fork do
28c28
<      # end
---
>      end

So, using *J*Ruby, after the solr.rake file change above, start it up.

rake solr:start  

You should now be able to see the solr admin page, allowing you to run test queries, see the schema, etc.
http://127.0.0.1:8982/solr/admin/

You need at least one Project in your db or the search currently fails.

I've got ObjectSpace disabled, but it can be turned on http://kenai.com/projects/jruby/pages/PerformanceTuning


My local gems are:

*** LOCAL GEMS ***

actionmailer (2.3.2, 2.2.2)   : I have two versions of rails because I'm working two projects
actionpack (2.3.2, 2.2.2)
activerecord (2.3.2, 2.2.2)
activerecord-jdbc-adapter (0.9.1)
activerecord-jdbcmysql-adapter (0.9.1)
activeresource (2.3.2, 2.2.2)
activesupport (2.3.2, 2.2.2)
allison (2.0.3)
builder (2.1.2)
daemons (1.0.10)
eventmachine (0.12.6)
fastercsv (1.4.0)
gchartrb (0.8)
gem_plugin (0.2.3)
icalendar (1.1.0)
image_voodoo (0.6)     : image_voodoo has yet to be used, plan to replace RMagick
jdbc-mysql (5.0.4)
markaby (0.5)
mislav-will_paginate (2.3.8)
mongrel (1.1.5)        : totally up to you, but I'm using WebRick 
rack (1.0.0)
rails (2.3.2, 2.2.2)
rake (0.8.7)
RedCloth (4.1.9)
rspec (1.2.6)
ruby-debug-base (0.10.3.1)  : needed only for NetBeans or other IDE
ruby-debug-ide (0.3.4)      : needed only for NetBeans or other IDE
sources (0.0.1)
splattael-activerecord_base_without_table (0.1.1)
tzinfo (0.3.13)
ZenTest (4.0.0)



