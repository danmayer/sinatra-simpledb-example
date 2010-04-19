require "rubygems"
require "sinatra"
require 'dm-core'
require 'dm-adapter-simpledb'

# This is an example app trying to show the most simple and basic example of how to work with Amazon's SimpleDB
# with Sinatra. It isn't a good example of Sinatra code or approaches. In fact please don't built Sinatra apps that
# use get requests to build and delete objects! This is just the simplest thing I could put together that shows how to interact with
# SDB from Sinatra, please contact dan <at> mayerdan.com if you have any issues or questions.

#pass these into the script of set them in your environment using something like .bash_profile
access_key  = ENV['AMAZON_ACCESS_KEY_ID']
secret_key  = ENV['AMAZON_SECRET_ACCESS_KEY']

DOMAIN_FILE_MESSAGE = <<END
!!! ATTENTION !!!
In order to operate, these specs need a throwaway SimpleDB domain to operate
in. This domain WILL BE DELETED BEFORE EVERY SUITE IS RUN. In order to 
avoid unexpected data loss, you are required to manually configure the 
throwaway domain. In order to configure the domain, create a file in the
project root directory named THROW_AWAY_SDB_DOMAIN. It's contents should be 
the name of the SimpleDB domain to use for tests. E.g.

    $ echo dm_simpledb_adapter_test > THROW_AWAY_SDB_DOMAIN

END
 #fixes syntax highlighting ' 

ROOT = File.expand_path('./', File.dirname(__FILE__))
domain_file = File.join(ROOT, 'THROW_AWAY_SDB_DOMAIN')
test_domain = if File.exist?(domain_file)
                File.read(domain_file).strip
              else
                warn DOMAIN_FILE_MESSAGE
                exit 1
              end

#configure and setup our datamapper connection to AWS simple DB
DataMapper.setup(:default,
                 :adapter       => 'simpledb',
                  :access_key    => access_key,
                  :secret_key    => secret_key,
                  :domain        => test_domain
                  )

class Post
  include DataMapper::Resource

  property :id,    Integer, :key => true
  property :title, String

  def to_s
    "#{self.id}::#{title}"
  end
end

#Post.auto_migrate!

get '/' do
  posts = Post.all
  html = 'view posts:<br/>'
  posts.each do |post|
    html += "post: #{post.title} - <a href='/delete?id=#{post.id}'>delete</a><br/>"
  end
  html += "<br/><a href='/create?title=new_post'>create new post</a>"
  html
end

get '/create' do
  title = params.fetch('title')
  id = params.fetch('id'){ rand(99999) }
  @article = Post.new(:id => id, :title => title)
  @article.save
  "article created -> #{@article}</br><a href='/'>back</a>"
end

get '/delete' do
  id = params.fetch('id')
  @article = Post.first(:id => id)
  @article.destroy
  sleep(1.5) #simpleDB takes awhile to remove an item
  redirect '/'
end
