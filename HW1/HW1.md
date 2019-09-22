# HW1

## Install FreeBSD
基本上按照pdf一步一步進行即可完成安裝
*  設定DNS
當時以為設定DHCP後，DNS也會自動修改，所以就沒特別動它(pdf p.26)，但建立起來時會有時會噴類似以下的錯誤
```
 **Unmatched Entries**
 gethostby*.getanswer: asked for "ip130.208-100-19.vswitch.static.steadfast.net  IN A", got type "39" : 6 time(s)
 Address 85.17.189.146 maps to hosted-by.leaseweb.com , but this does not map back to the address - POSSIBLE BREAK-IN ATTEMPT! : 2 time(s)
 gethostby*.getanswer: asked for "ip130.208-100-19.vswitch.static.steadfast.net  IN AAAA", got type "39" : 4 time(s)
```
(source:https://www.linuxquestions.org/questions/linux-newbie-8/what-is-gethostby%2A-getanswer-asked-for-876793/)
後來發現是DNS沒有設定好，第一種解法是更改`/etc/resolv.conf`，在最下面加上
```
nameserver 8.8.8.8
```
但這種方法每次重開機都要重新設定，非常麻煩。
第二種解法是更改`/etc/dhclient.conf`，在裡面加上
```
interface"hn0" {
 supersede domain-name-servers 8.8.8.8;
}
```
並且重新啟動`dhclient`
```
# service dhclient restart hn0
```
即可正確更改
(source:https://www.helplib.com/yunwei/article_178807)
## Install WireGuard
```
# sudo pkg install wireguard
```
* 設定wg0.conf
```
[Interface]
Address =  # 填入助教分配的Peer IP
PrivateKey =  # 填入Private Key

[Peer]
AllowedIPs =  # 10.113.0.0/16
Endpoint =  # 填入Server
PublicKey =  # 填入Public Key
PersistentKeepalive =  25
```
(source:https://github.com/wgredlong/WireGuard/blob/master/2.%E7%94%A8%20wg-quick%20%E8%B0%83%E7%94%A8%20wg0.conf%20%E7%AE%A1%E7%90%86%20WireGuard.md)
