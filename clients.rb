#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'openssl'

def count_users(devices)

  devices.each do |name,device|
    uri = "wget --timeout=2 https://#{device} --user=admin --password=s2iabos --no-check-certificate -qO-"
    uri = "curl -k --user admin:s2iabos https://#{device}"

    data = ''
    f = open("|" + uri)
    while (line = f.gets)
      data = data + line  
    end #(loops forever)
    
    parsed = Nokogiri::HTML(data)
    amount = (parsed.xpath('//table/tr/td/table/tr').count - 1)

    puts "#{name}: #{amount}"
  end

end

devices = {
  "Toilet" => '192.168.48.11/ngadmin.cgi?action=clients',
  "Door" => '192.168.48.12/ngadmin.cgi?action=clients',
  "Desk" => '192.168.48.13/stalist.htm',
#  "Cafe" => '192.168.48.23/stalist.htm',
  "DJ" => '192.168.48.16/stalist.htm',
  "Stage" => '192.168.48.24/stalist.htm',
}

puts count_users(devices)
