<?php
require_once 'config.inc.php';
require_once 'mysql_sessions.inc.php';
require_once 'libs/lang.lib.php';
require_once 'libs/sf.lib.php';

define('inc', 'includes' . DIRECTORY_SEPARATOR);
$_GET['section'] = (isset($_GET['section']) && !empty($_GET['section'])) ? $_GET['section'] : 'home';
sess_init(DBHOST,DBNAME_WWW,DBUSER,DBPASS,'');
mysql_select_db(DBNAME_WWW, mysql_pconnect(DBHOST,DBUSER,DBPASS)) or die(mysql_error());
//session_start();

if(isset($_GET['lang'])) {
  setLangKey($_GET['lang']);
}

header('Content-type: text/html;charset=utf-8');
?>
