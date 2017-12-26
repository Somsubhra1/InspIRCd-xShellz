#!/usr/bin/env bash

# InspIRCd provision script, written by Som
set -e
set -u

_author="Som / somsubhra1 [at] xshellz.com"
_package="InspIRCd"
_version="2.0.24"

echo "Running provision for package $_package version: $_version by $_author"

cd ~

dir="inspircd-2.0.24"

if [ -d $dir ]
then
 echo "$dir is already present in $HOME. Aborting!"
 exit
fi

if pgrep inspircd >/dev/null 2>&1
then
 echo "InspIRCd is already running. Aborting installation!"
 exit 
fi

wget https://github.com/inspircd/inspircd/archive/v2.0.24.tar.gz

tar xvzf v2.0.24.tar.gz

cd 'inspircd-2.0.24'

/usr/bin/expect - <<-EOF
spawn ./configure
set timeout 15
expect "In what directory do you wish to install the InspIRCd base?"
send "\r"
send "y"
expect "In what directory are the configuration files?"
send "\r"
send "y"
expect "In what directory are the modules to be compiled to?"
send "\r"
send "y"
expect "In what directory is the IRCd binary to be placed?"
send "\r"
send "y"
expect "In what directory are variable data files to be located in?"
send "\r"
send "y"
expect "In what directory are the logs to be stored in?"
send "\r"
send "y"
expect "In what directory do you want the build to take place?"
send "\r"
send "y"
expect "Enable epoll?"
send "y"
expect "Would you like to check for updates to third-party modules?"
send "\r"
set timeout 300
expect -ex "$prompt"
expect eof
EOF

make
make install

cd ~

cd '$dir/run/conf'
rm inspircd.conf

cat << EOF > inspircd.conf

# https://www.xshellz.com/

<server name="$servername"
 description="$desc"
 network="$network">

 <admin name="$adminname"
 nick="$nick"
 email="$adminemail">

 <bind address="" port="$port" type="clients">
 <bind address="" port="6697" ssl="openssl">

 <power diepass="$password" restartpass="$password" pause="2">

 <include file="file.conf"> 

 <connect allow="196.12.*" password="secret">
 <connect allow="*" timeout="60" flood="20" threshold="1" pingfreq="120" sendq="262144" recvq="8192" localmax="3" globalmax="3">
 <connect allow="*" port="6660">
 <connect deny="69.254.*">
 <connect deny="3ffe::0/32">

 <class name="Shutdown" commands="DIE RESTART REHASH LOADMODULE UNLOADMODULE RELOAD">
 <class name="ServerLink" commands="CONNECT SQUIT RCONNECT MKPASSWD MKSHA256">
 <class name="BanControl" commands="KILL GLINE KLINE ZLINE QLINE ELINE">
 <class name="OperChat" commands="WALLOPS GLOBOPS SETIDLE SPYLIST SPYNAMES">
 <class name="HostCloak" commands="SETHOST SETIDENT SETNAME CHGHOST CHGIDENT">

 <type name="NetAdmin" classes="OperChat BanControl HostCloak Shutdown ServerLink" host="netadmin.$servername">
 <type name="GlobalOp" classes="OperChat BanControl HostCloak ServerLink" host="ircop.$servername">
 <type name="Helper" classes="HostCloak" host="helper.$servername">

 <oper name="$opername"
 password="$operpass"
 host="$operhost"
 type="NetAdmin">
 

 <link name="services.$servername"
 ipaddr="$servicesip"
 port="7000"
 allowmask="127.0.0.0/8"
 sendpass="$linkpass"
 recvpass="$linkpass">

 <uline server="services.$servername" silent="yes">

 <files motd="inspircd.motd"
 rules="inspircd.rules">

 <channels users="20"
 opers="60">

 <dns server="127.0.0.1" timeout="5">

 <dns server="::1" timeout="5">

 <pid file="$HOME/$dir/run/inspircd.pid">

 <banlist chan="#morons" limit="128">
 <banlist chan="*" limit="69">

 <disabled commands="TOPIC MODE">

 <die value="You should probably edit your config *PROPERLY* and try again.">

 <options prefixquit="Quit: "
 loglevel="default"
 netbuffersize="10240"
 maxwho="128"
 noservices="no"
 qaprefixes="no"
 deprotectself="no"
 somaxconn="128"
 softlimit="12800"
 userstats="Pu"
 operspywhois="no"
 customversion=""
 maxtargets="20"
 hidesplits="no"
 hidebans="no"
 hidewhois=""
 flatlinks="no"
 hideulines="no"
 nouserdns="no"
 syntaxhints="no"
 cyclehosts="yes"
 ircumsgprefix="no"
 announcets="yes"
 hostintopic="yes"
 allowhalfop="yes"
 announceinvites="yes"
 quietbursts="no"
 hidekills="no"
 exemptchanops=""
 moronbanner="">

 <whowas groupsize="10" 
 maxgroups="100000" 
 maxkeep="3d"> 


 <module name="m_spanningtree.so">

 <module name="m_md5.so">

 <module name="m_sha256.so">

 <module name="m_alias.so">
 <alias text="NICKSERV" replace="PRIVMSG NickServ :$2-" requires="NickServ" uline="yes">
 <alias text="CHANSERV" replace="PRIVMSG ChanServ :$2-" requires="ChanServ" uline="yes">
 <alias text="OPERSERV" replace="PRIVMSG OperServ :$2-" requires="OperServ" uline="yes" operonly="yes">
 <alias text="NS" replace="PRIVMSG NickServ :$2-" requires="NickServ" uline="yes">
 <alias text="CS" replace="PRIVMSG ChanServ :$2-" requires="ChanServ" uline="yes">
 <alias text="OS" replace="PRIVMSG OperServ :$2-" requires="OperServ" uline="yes" operonly="yes">
 <alias text="ID" format="#*" replace="PRIVMSG ChanServ :IDENTIFY $2 $3"
 requires="ChanServ" uline="yes">
 <alias text="ID" replace="PRIVMSG NickServ :IDENTIFY $2"
 requires="NickServ" uline="yes">
 <alias text="NICKSERV" format=":IDENTIFY *" replace="PRIVMSG NickServ :IDENTIFY $3-"
 requires="NickServ" uline="yes">

 <module name="m_alltime.so">

 <module name="m_antibear.so">

 <module name="m_antibottler.so">

 <module name="m_banexception.so">

 <module name="m_banredirect.so">

 <module name="m_blockamsg.so">
 <blockamsg delay="3" action="killopers">

 <module name="m_blockcaps.so">
 <blockcaps percent="50"
 minlen="5"
 capsmap="ABCDEFGHIJKLMNOPQRSTUVWXYZ! ">

 <module name="m_blockcolor.so">

 <module name="m_botmode.so">

 <module name="m_cban.so">

 <module name="m_censor.so">
 <include file="censor.conf">

 <module name="m_cgiirc.so">
 <cgiirc opernotice="no">
 <cgihost type="pass" mask="www.mysite.com">
 <cgihost type="webirc" mask="somebox.mysite.com">
 <cgihost type="ident" mask="otherbox.mysite.com">
 <cgihost type="passfirst" mask="www.mysite.com"> 

 <module name="m_chanfilter.so">

 <module name="m_chanprotect.so">

 <module name="m_chghost.so">

 <module name="m_chgident.so">

 <module name="m_cloaking.so">
 <cloak key1="0x2AF39F40" 
 key2="0x78E10B32" 
 key3="0x4F2D2E82" 
 key4="0x043A4C81" 
 prefix="mynet"> 
 
 <module name="m_conn_join.so">
 <autojoin channel="#one,#two,#three">

 <module name="m_conn_umodes.so">

 <module name="m_conn_waitpong.so">
 <waitpong sendsnotice="yes" killonbadreply="yes">

 <module name="[[Modules/connflood|m_connflood.so">
 <connflood seconds="30" maxconns="3" timeout="30"
 quitmsg="Throttled" bootwait="10">

 <module name="m_dccallow.so">
 <dccallow blockchat="yes" length="5m" action="block">
 <banfile pattern="*.exe" action="block">
 <banfile pattern="*.txt" action="allow">

 <module name="m_deaf.so">

 <module name="m_denychans.so"> 
 <badchan name="#gods" allowopers="yes" reason="Tortoises!">

 <module name="m_devoice.so">

 <module name="m_dnsbl.so"> 

 <module name="m_filter.so">
 <module name="m_filter_pcre.so">
 <include file="filter.conf">

 <module name="m_foobar.so">

 <module name="m_globops.so">

 <module name="m_globalload.so">

 <module name="m_helpop.so">
 <include file="helpop.conf">

 <module name="m_hidechans.so">

 <module name="m_hideoper.so">

 <module name="m_hostchange.so">
 <host suffix="polarbears.org">
 <hostchange mask="*@fbi.gov" action="addnick">
 <hostchange mask="*r00t@*" action="suffix">
 <hostchange mask="a@b.com" action="set" value="blah.blah.blah">

 <module name="m_httpd.so">
 <http ip="192.168.1.10" host="brainwave" port="32006"
 index="/home/brain/inspircd/http/index.html">

 <module name="m_httpd_stats.so">
 <httpstats stylesheet="http://remote.style/sheet.css">

 <module name="m_ident.so">
 <ident timeout="5">

 <module name="m_inviteexception.so">

 <module name="m_joinflood.so">

 <module name="m_jumpserver.so">

 <module name="m_kicknorejoin.so">

 <module name="m_knock.so">

 <module name="m_lockserv.so">

 <module name="m_messageflood.so">

 <module name="m_mysql.so">
 <database name="mydb" username="myuser" password="mypass" hostname="localhost" id="my_database2">

 <module name="m_namesx.so">

 <module name="m_nicklock.so">

 <module name="m_noctcp.so">

 <module name="m_noinvite.so">

 <module name="m_nokicks.so">

 <module name="m_nonicks.so">

 <module name="m_nonotice.so">

 <module name="m_operchans.so">

 <module name="m_oper_hash.so">

 <module name="m_operjoin.so">
 <operjoin channel="#channel">

 <module name="m_opermotd.so">
 <opermotd file="oper.motd">

 <module name="m_override.so">

 <module name="m_operlevels.so">

 <module name="m_opermodes.so">

 <module name="m_pgsql.so">
 <database name="mydb" username="myuser" password="mypass" hostname="localhost" id="my_database" ssl="no">

 <module name="m_randquote.so>
 <randquote file="randquotes.conf">

 <module name="m_redirect.so">

 <module name="m_remove.so">

 <module name="m_restrictbanned.so">

 <module name="m_restrictchans.so">

 <module name="m_restrictmsg.so">
 
 <module name="m_safelist.so">
 <safelist throttle="60" maxlisters="50">
 
 <module name="m_sajoin.so">
 
 <module name="m_samode.so">
 
 <module name="m_sanick.so">

 <module name="m_sapart.so">

 <module name="m_saquit.so">

 <module name="m_securelist.so">
 <securelist exception="*@*.searchirc.org">
 <securelist exception="*@*.netsplit.de">
 <securelist exception="*@echo940.server4you.de">
 <securelist waittime="60"> 

 <module name="m_seenicks.so">

 <module name="m_setidle.so">

 <module name="m_services.so">

 <module name="m_services_account.so">

 <module name="m_sethost.so">

 <module name="m_setident.so">

 <module name="m_setname.so">

 <module name="m_showwhois.so">

 <module name="m_spy.so">

 <module name="m_sslmodes.so">

 <module name="m_ssl_dummy.so">

 <module name="m_ssl_gnutls.so">

 <module name="m_sslinfo.so">

 <module name="m_ssl_oper_cert.so">

 <module name="m_stripcolor.so">

 <module name="m_silence.so">

 <module name="m_silence_ext.so">

 <module name="m_sqlite3.so">
 <database hostname="/full/path/to/database.db" id="anytext">

 <module name="m_sqlutils.so">

 <module name="m_sqlauth.so">

 <module name="m_sqllog.so">
 <sqllog dbid="1">

 <module name="m_sqloper.so">
 <sqloper dbid="1">

 <module name="m_svshold.so">

 <module name="m_swhois.so">

 <module name="m_testcommand.so">

 <module name="m_timedbans.so">

 <module name="m_tline.so">

 <module name="m_uninvite.so">

 <module name="m_userip.so">

 <module name="m_vhost.so">
 <vhost user="some_username" pass="some_password" host="some.host">

 <module name="m_watch.so">

 <module name="m_ziplink.so">

 <badip ipmask="69.69.69.69" reason="No porn here thanks.">

 <badnick nick="ChanServ" reason="Reserved For Services">
 <badnick nick="NickServ" reason="Reserved For Services">
 <badnick nick="OperServ" reason="Reserved For Services">
 <badnick nick="MemoServ" reason="Reserved For Services">

 <badhost host="*@hundredz.n.hundredz.o.1337.kiddies.com" reason="Too many 1337 kiddiots">
 <badhost host="*@localhost" reason="No irc from localhost!">
 <badhost host="*@172.32.0.0/16" reason="This subnet is bad.">

 <exception host="*@ircop.host.com" reason="Opers hostname">

 <insane hostmasks="no" ipmasks="no" nickmasks="no" trigger="95.5">

 <die value="No, i wasnt joking. You should probably edit your config *PROPERLY* and try again.">

EOF

cd ~
cd '$dir/run/conf'

touch inspircd.motd
touch inspircd.rules

cd '$HOME/$dir'

chmod +x inspircd
./inspircd start

#cleanup
cd ~
rm v2.0.24.tar.gz

#Check if inspircd ran successfully or not.
if pgrep inspircd >/dev/null 2>&1
then
 echo "InspIRCd is running successfully"
else
 echo "Error occured"
 exit 
fi

echo "Provision done, successfully."
			