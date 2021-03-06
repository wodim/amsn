##############################################################################
# Socks5 Client Library v1.1
#     (C)2000 Kerem 'Waster_' HADIMLI
#
# How to use:
#   1) Create your socket connected to the Socks server.
#   2) Call socks:init procedure with these 6 parameters:
#        1- Socket ID : The socket identifier that's connected to the socks5 server.
#        2- Server hostname : The main (not socks) server you want to connect
#        3- Server port : The port you want to connect on the main server
#        4- Authentication : If you want username/password authentication enabled, set this to 1, otherwise 0.
#        5- Username : Username to use on Socks Server if authentication is enabled. NULL if authentication is not enabled.
#        6- Password : Password to use on Socks Server if authentication is enabled. NULL if authentication is not enabled.
#   3) It'll return you a string starting with:
#        a- "OK" if successful, now you can send/receive any data from the socket.
#        b- "ERROR:$explanation" if unsuccessful, $explanation is the explanation like "Host not found". The socket will be automatically closed on an error.
#
#
# Notes:
#   - This library enters tkwait ::Socks5::loop (see Tk man pages), and returns only
#     when SOCKS initialization is complete.
#   - This library uses a global array: socks_idlist. Make sure your program
#     doesn't use that.
#   - NEVER use file IDs instead of socket IDs!
#   - NEVER bind the socket (fileevent) before calling socks:init procedure.
##############################################################################
#
# Author contact information:
#   E-mail :  waster@iname.com
#   ICQ#   :  27216346
#   Jabber :  waster@jabber.org   (New IM System - http://www.jabber.org)
#
##############################################################################
# $Id$
#set socks_idlist(stat,$sck) ...
#set socks_idlist(data,$sck) ...

namespace eval ::Socks5 {

	proc Init {sck addr port auth user pass} {
		variable socks_idlist
		
		#  if { [catch {fconfigure $sck}] != 0 } {return "ERROR:Connection closed with Socks Server!"}    ;# Socket doesn't exist
		
		set ver "\x05"               ;#Socks version
		
		status_log "SOCKS : $sck    $addr\n"
		set addr [split $addr " "]   ;# Remove port from address
		set addr [lindex $addr 0]
		status_log "SOCKS : $addr\n"
		
		if {$auth==0} {
			set method "\x00"
			set nmethods "\x01"
		} elseif {$auth==1} {
			set method "\x00\x02"
			set nmethods "\x02"
		} else {
			status_log "ERROR: $auth"
			return "ERROR:"
		}
		set nomatchingmethod "\xFF"  ;#No matching methods
		
		set cmd_connect "\x01"  ;#Connect command
		set rsv "\x00"          ;#Reserved
		set atyp "\x03"         ;#Address Type (domain)
		set dlen "[binary format c [string length $addr]]" ;#Domain length (binary 1 byte)
		set port [binary format S $port] ;#Network byte-ordered port (2 binary-bytes)
		
		set authver "\x01"  ;#User/Pass auth. version
		set ulen "[binary format c [string length $user]]"  ;#Username length (binary 1 byte)
		set plen "[binary format c [string length $pass]]"  ;#Password length (binary 1 byte)
		
		set a ""
		
		set socks_idlist(stat,$sck) 0
		set socks_idlist(data,$sck) ""
		
		status_log "doing fconfigure now in socks5\n"	
		fconfigure $sck -translation {binary binary} -blocking 0
		
		status_log "writing to socket in socks5 writing : $ver$nmethods$method\n"
		puts -nonewline $sck "$ver$nmethods$method"
		
		if { [catch { flush $sck }] } {
		    catch {close $sck}
		    status_log "ERROR:Couldn't flush Socks Server after writing!"
		    return "ERROR:Couldn't flush Socks Server after writing!"
		}
		
		status_log "doing fileevent now in socks5\n"
		fileevent $sck readable "::Socks5::Readable $sck"

		status_log "going into tkwait\n"
		tkwait variable ::Socks5::socks_idlist(stat,$sck)
		set a $socks_idlist(data,$sck)
		if {[eof $sck]} {
			catch {close $sck}
			status_log "ERROR:Connection closed with Socks Server!"
			return "ERROR:Connection closed with Socks Server!"
		}
		
		set serv_ver ""
		set method $nomatchingmethod
		
		binary scan $a "cc" serv_ver smethod
		
		if {$serv_ver!=5} {
			catch {close $sck}
			status_log "ERROR:Socks Server isn't version 5!"
			return "ERROR:Socks Server isn't version 5!"
		}
		
		if {$smethod==0} {
		} elseif {$smethod==2} {  ;#User/Pass authorization required
			if {$auth==0} {
				catch {close $sck}
				status_log "ERROR:Method not supported by Socks Server!"
				return "ERROR:Method not supported by Socks Server!"
			}
			    
			puts -nonewline $sck "$authver$ulen$user$plen$pass"
			flush $sck
			
			tkwait variable ::Socks5::socks_idlist(stat,$sck)
			set a $socks_idlist(data,$sck)
			if {[eof $sck]} {
				catch {close $sck}
				status_log "ERROR:Connection closed with Socks Server!"
				return "ERROR:Connection closed with Socks Server!"
			}
			
			set auth_ver ""
			set status "\x00"
			binary scan $a "cc" auth_ver status
			
			if {$auth_ver!=1} {
				catch {close $sck} 
				status_log "ERROR:Socks Server's authentication isn't supported!"
				return "ERROR:Socks Server's authentication isn't supported!"
			}
			if {$status!=0} {
				catch {close $sck}
				status_log "ERROR:Wrong username or password!"
				return "ERROR:Wrong username or password!"
			}
			
		} else {
			fileevent $sck readable {}
			unset socks_idlist(stat,$sck)
			unset socks_idlist(data,$sck)
			catch {close $sck}
			status_log "ERROR:Method not supported by Socks Server!"
			return "ERROR:Method not supported by Socks Server!"
		}
		
		#
		# We send request4connect
		#
		
		status_log "second write\n"
		puts -nonewline $sck "$ver$cmd_connect$rsv$atyp$dlen$addr$port"
		flush $sck
		
		tkwait variable ::Socks5::socks_idlist(stat,$sck)
		set a $socks_idlist(data,$sck)
		if {[eof $sck]} {
			catch {close $sck}
			status_log "ERROR:Connection closed with Socks Server!"
			return "ERROR:Connection closed with Socks Server!"
		}
		
		fileevent $sck readable {}
		unset socks_idlist(stat,$sck)
		unset socks_idlist(data,$sck)
		
		set serv_ver ""
		set rep ""
		binary scan $a cc serv_ver rep
		if {$serv_ver!=5} {
			catch {close $sck}
			status_log "ERROR:Socks Server isn't version 5!"
			return "ERROR:Socks Server isn't version 5!"
		}

		if {$rep==0} {
			fconfigure $sck -translation {auto auto}
			status_log "SOCKS: OK"
			return "OK"
		} elseif {$rep==1} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nGeneral SOCKS server failure"
			return "ERROR:Socks server responded:\nGeneral SOCKS server failure"
		} elseif {$rep==2} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nConnection not allowed by ruleset"
			return "ERROR:Socks server responded:\nConnection not allowed by ruleset"
		} elseif {$rep==3} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nNetwork unreachable"
			return "ERROR:Socks server responded:\nNetwork unreachable"
		} elseif {$rep==4} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nHost unreachable"
			return "ERROR:Socks server responded:\nHost unreachable"
		} elseif {$rep==5} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nConnection refused"
			return "ERROR:Socks server responded:\nConnection refused"
		} elseif {$rep==6} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nTTL expired"
			return "ERROR:Socks server responded:\nTTL expired"
		} elseif {$rep==7} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nCommand not supported"
			return "ERROR:Socks server responded:\nCommand not supported"
		} elseif {$rep==8} {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nAddress type not supported"
			return "ERROR:Socks server responded:\nAddress type not supported"
		} else {
			catch {close $sck}
			status_log "ERROR:Socks server responded:\nUnknown Error"
			return "ERROR:Socks server responded:\nUnknown Error"
		}


		status_log "finished sock5 init"
	}

	#
	# Change the variable value, so 'tkwait' loop will end in socks:init procedure.
	#
	proc Readable {sck} {
		variable socks_idlist

		if { [catch {set socks_idlist(data,$sck) [read $sck]} res] } {
			status_log "Error when reading from sock server : $res"
		}

		incr socks_idlist(stat,$sck)
	}
}
