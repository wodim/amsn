<?php
   define('source', 'plugins');
   include 'common.php';
   include inc . 'init.php';

   echo '<link rel="stylesheet" type="text/css" media="screen" href="plugins.css" />';

   include inc . 'header.php';
?>


        <strong>aMSN is full of features</strong>, but you can extend its functionality even more now, getting extra features by installing plugins. Plugins are simply that - they "plug in" to aMSN and give it extra features. Here you can download plugins developed by us and by contributors. Make sure you have the right version of aMSN for the plugin (check "requirements") and the right OS (check "platform")
        <br /><br />
        You can find instructions on how to install plugins in our <a href="http://amsn.sourceforge.net/wiki/tiki-index.php?page=Installing+Plugins+and+Skins">skin and plugin installation guide</a>.
        <br /><br />
	If you would like to submit your plugin to this page, please read the <a href="http://amsn.sourceforge.net/wiki/tiki-index.php?page=Skin+and+plugin+submitting+guide">plugin submitting guide</a>.
<br /><br />

<a NAME="top"> </a>

<?php

$toc_arrays = $plugins;
include inc . 'toc.php';

foreach($plugins as $plugin) {
        echo '<a NAME="' . $plugin[0] . '">';
	echo '<table class="plugins">';
	echo ' <tr><td>';
	echo '  <ul>';
	echo '   <li class="plugintitle">'.$plugin[0].'</li>';
	echo '   <li class="lg">Author: '.$plugin[2].'</li>';
	echo '   <li class="dg">Version: '.$plugin[3].'</li>';
	echo '   <li class="lg">Platform/OS: '.$plugin[4].'</li>';
	echo '   <li class="dg">Requires: '.$plugin[5].'</li>';
	echo '   <li class="lg">'.$plugin[1].'</li>';
	if($plugin[6]>0)
		echo '   <li class="dg"><a href="http://amsn.sourceforge.net/wiki/show_image.php?id='.$plugin[6].'"><strong>Screenshot</strong></a></li>';
	if($plugin[7]!='')
		echo '   <li class="lg"><a href="http://prdownloads.sourceforge.net/amsn/'.$plugin[7].'"><strong>Download this plugin</strong></a></li>';
	echo '  </ul>';
	echo ' </td></tr>';
	echo '</table>';
	echo '<br/>';
	echo '<a/>';
}
?>

<br/><br/>
<center><strong><a href="#top">Back to top</a></strong></center>


<?php include inc . 'footer.php'; ?>
