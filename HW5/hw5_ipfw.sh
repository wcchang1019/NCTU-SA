sudo ipfw table BadHost create
sudo ipfw table BadGuy create
ipfw add 2000 deny all from "table(BadHost)" to any in
#ipfw add 2010 allow tcp from 10.113.0.0/16 to any 80 in
#ipfw add 2011 allow tcp from 10.113.0.0/16 to any 443 in
ipfw add 2020 allow icmp from 10.113.0.254 to any in
ipfw add 2025 deny icmp from any to any in
ipfw add 2030 reset tcp from "table(BadGuy)" to any 21 in
ipfw add 2031 reset tcp from "table(BadGuy)" to any 22 in
