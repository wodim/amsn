
  </head>

  <body>

    <div id="title" class="center">

<?php
    $dir="images/logo/";
    $files=array();
    $dh=opendir($dir);
    while($file=readdir($dh)) {
           $file=$dir.'/'.$file;
           if(is_file($file)) {
                   $files[]=$file;
           }
    }
    $img=rand(0,count($files)-1);
    echo '<img alt="aMSN Logo" src="'.$files[$img].'" />';
?>
    </div>

    <div id="nav" class="center">
<?php
    
	if (source == 'index') define(nav_index, 'nav_on');
	else define(nav_index, 'nav');
        if (source == 'download') define(nav_download, 'nav_on');
        else define(nav_download, 'nav');
        if (source == 'features') define(nav_features, 'nav_on');
        else define(nav_features, 'nav');
        if (source == 'skins') define(nav_skins, 'nav_on');
        else define(nav_skins, 'nav');
        if (source == 'plugins') define(nav_plugins, 'nav_on');
        else define(nav_plugins, 'nav');
        if (source == 'screenshots') define(nav_screenshots, 'nav_on');
        else define(nav_screenshots, 'nav');
        if (source == 'docs') define(nav_docs, 'nav_on');
        else define(nav_docs, 'nav');
        if (source == 'developer') define(nav_developer, 'nav_on');
        else define(nav_developer, 'nav');

        echo '<a class="'.nav_index.'" href="index.php">'.trans('home').'</a>';
        echo '<a class="'.nav_download.'" href="download.php">'.trans('download').'</a>';
        echo '<a class="'.nav_features.'" href="features.php">'.trans('features').'</a>';
        echo '<a class="'.nav_skins.'" href="skins.php">'.trans('skins').'</a>';
        echo '<a class="'.nav_plugins.'" href="plugins.php">'.trans('plugins').'</a>';
        echo '<a class="'.nav_screenshots.'" href="screenshots.php">'.trans('screenshots').'</a>';
        echo '<a class="'.nav_docs.'" href="docs.php">'.trans('docs').'</a>';
        echo '<a class="'.nav_developer.'" href="developer.php">'.trans('development').'</a>';
?>
    </div>

<div id="<?php $navigator_user_agent = ( isset( $_SERVER['HTTP_USER_AGENT'] ) ) ? strtolower( $_SERVER['HTTP_USER_AGENT'] ) : '';
print ((stristr($navigator_user_agent, "konqueror")) || (stristr($navigator_user_agent, "safari"))?"container_mac":"container"); ?>" class="center">

      &nbsp;



<div class="top_ad">
<script type="text/javascript"><!--
google_ad_client = "pub-4657753156267954";
google_ad_width = 728;
google_ad_height = 90;
google_ad_format = "728x90_as";
google_ad_type = "text";
//2006-10-03: amsn
google_ad_channel ="7037776257";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>

</div>

    <div id="blurb">
       &nbsp;  <!--Spacing fix--> <br />

