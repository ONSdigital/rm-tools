#!/usr/bin/env ruby

require 'net/http'

fmt = 'xx.xx , xx.xx.xx or xx.xx.x'
error = "Usage: eq_flush_script.rb <artifactory.username> \
      <artifactory.password> <service> <pomversion[optional]> \
      <pomversion> can be of the form #{fmt}"

unless ARGV.length >= 4 && ARGV.length <= 5
  puts error
  exit
end

services = ["actionsvc","actionexportersvc","casesvc","collectionexercisesvc", \
  "iacsvc","samplesvc","surveysvc","notifygatewaysvc","sdxgatewaysvc"]

unless services.include? ARGV[3]
  puts "Error! service <#{ARGV[3]}> not found!"
  exit
end

uname=ARGV[0]
passwd=ARGV[1]
host=ARGV[2]
service=ARGV[3]
version= nil
survey=false
if service.match(/surveysvc/)
  survey=true
end

if ARGV[4]
  if (ARGV[4].match(/^[0-9]{2}\.[0-9]{2}$/) || \
    ARGV[4].match(/^([0-9]{2}\.){2}[0-9]{1,2}$/)) || \
    ARGV[4].match(/^[0-9]{2,3}$/) && survey
    version = ARGV[4]
  else
    puts "#{ARGV[4]} is the wrong format, must be of the form #{fmt}."
    exit
  end
end

if survey
  ext = 'tar'
else
  ext = 'jar'
end

url="http://#{host}/artifactory/api/search/artifact?name=#{service}*#{version}*#{ext}&repos=libs-snapshot-local"

def createreq(uri)
  request = Net::HTTP::Get.new(uri)
  request.basic_auth $uname, $passwd
  return request
end

begin
  uri = URI(url)

  result = Net::HTTP.start(uri.hostname,80) {|http|
    http.request(createreq(uri))
  }
rescue SocketError
  puts "Host <#{host} not found!"
  exit
end

if result.body.match(/\"results\" \: \[ \]/)
  puts "Version #{version} not found for #{service}"
  exit
end

result.body.delete! "\"\}\]\s\n\{\["
result.body.gsub!('results:uri:','')
result.body.gsub!('api/storage/','')
snapshots = result.body.split("\,uri\:")

if survey
  result.body.gsub!(%r{[a-zA-Z\.\/\-\:]*},'')
  versions = result.body.split("\,")
  versions = versions.map(&:to_i)
  versions.sort!
  if version == nil
    version = versions[-1].to_s
    match = snapshots.each_index.select{|i| snapshots[i].match("-#{version}.")}
  else
    match = snapshots.each_index.select{|i| snapshots[i].match("-#{version.to_i}.")}
  end
  latest = snapshots[match[0].to_i]
else
  latest = snapshots[-1]
end

svc = "#{service}.#{ext}"

uri = URI(latest)
Net::HTTP.start(uri.hostname,80) do |http|
  puts "Downloading: #{latest}"
  resp = http.request(createreq(uri))
  open(svc, "wb") do |file|
      file.write(resp.body)
  end
end
