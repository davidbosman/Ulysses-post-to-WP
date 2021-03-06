#!/usr/bin/env ruby -E UTF-8:UTF-8

require 'xmlrpc/client'

wordpress = XMLRPC::Client.new_from_hash(
  { "host" => "yourblogurl.com",
    "user" => "yourWPusername",
    "password" => "yourWPpassword",
    "use_ssl" => nil,   #change to true if hosted on SSL
#-------------------------------------------------------
    "path" => "/xmlrpc.php"
  })

post = []
content = {}

ARGF.each_line do |line|
  next if "\n" == line
  post << line.chomp.gsub(/(a\s+)(href="[^#])/, '\1target="_blank" \2')
end

title = post.shift.gsub(/<\/*h1>/, '')
tags  = post.shift.gsub(/<\/*p>/, '').split(/,\s*/)

# Edit to change delay in hours:
delay = 2
post_time = Time.now + 60 * 60 * delay

content["post_title"]   = title
content["terms_names"]  = {"post_tag" => tags}
content["post_content"] = post.join("\n\n").sub(/<p>MORE<\/p>/, '<!--more-->')
content["post_status"]  = "future"
# Post time must be in UTC
content["post_date"]    = post_time.utc.strftime("%F %T")
 
begin
  postnum = wordpress.call(
    'wp.newPost',
    0,
    wordpress.user,
    wordpress.password,
    content,
  )

  puts "Posting Success! (##{postnum})"
rescue => err
  puts "Posting error: #{err}"
end

