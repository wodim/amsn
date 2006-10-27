<?php
error_reporting(0);

header("Content-type: text/plain");

function addr(){ 
	if (getenv('HTTP_X_FORWARDED_FOR')) {
		$ip = getenv('HTTP_X_FORWARD_FOR');
		return $ip;
	} else {
		$ip = getenv('REMOTE_ADDR');
		return $ip;
	}
}

if(!isset($_GET['port']) || !is_numeric($_GET['port'])) {
	echo "-1";
} else {

	$socket = @socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	if ($socket < 0) {
		echo "-1";
		return;
	}

	@socket_set_option( $socket, SOL_SOCKET, SO_SNDTIMEO, array("sec"=>10,"usec"=>0) );

	$result = @socket_connect($socket, addr(), $_GET['port']);

	if ($result == 0) {
		echo "0";
	} else {
		echo "1";
	}

	@socket_close($socket);
}
?>