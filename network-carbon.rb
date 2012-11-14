#!/usr/bin/env ruby
#
#

require 'rubygems'
require 'socket'

GRAPHITE_IP='127.0.0.1'
GRAPHITE_PORT=2003

interfaces = `ifconfig | grep 'Link encap'`.scan(/^(\w+)\s/)

gs = TCPSocket.new GRAPHITE_IP, GRAPHITE_PORT

interfaces.each{  |int| 
  traffic = `ifconfig #{int}`.scan(/.+RX packets:(\d+).*TX packets:(\d+).*RX bytes:(\d+).*TX bytes:(\d+)/m)
  gs.puts "buildrouter.#{int}.rxpackets #{traffic[0][0]} #{Time.now.to_i}"
  gs.puts "buildrouter.#{int}.txpackets #{traffic[0][1]} #{Time.now.to_i}"
  gs.puts "buildrouter.#{int}.rxbytes #{traffic[0][2]} #{Time.now.to_i}"
  gs.puts "buildrouter.#{int}.txbytes #{traffic[0][3]} #{Time.now.to_i}"
}

ip_conntrack_max = File.read('/proc/sys/net/ipv4/netfilter/ip_conntrack_max').chomp
gs.puts "buildrouter.ip_conntrack_max #{ip_conntrack_max} #{Time.now.to_i}"

ip_conntrack = `cat /proc/net/ip_conntrack | wc -l`.chomp
gs.puts "buildrouter.ip_conntrack #{ip_conntrack} #{Time.now.to_i}"

active_clients = `arp -an | grep -v incomplete | wc -l`.chomp
gs.puts "buildrouter.active_clients #{active_clients} #{Time.now.to_i}"

gs.close
