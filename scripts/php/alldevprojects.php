<h2>projects in development</h2>
<?php
$dir = "/ntaxa/z/";
$myDirectory = opendir("$dir");

// get each entry

$dirs = array();
$hidedirs = array('ResQ_blank');
$differenturls = array('ResQ_1_16'=>'http://r/');

$hidedirs = array_flip($hidedirs);
while($entryName = readdir($myDirectory)) {
        if (is_dir("$dir$entryName") && !preg_match("/^\./",$entryName) && (!isset($hidedirs[$entryName])) )
            {
            $dirs[$entryName] = isset($differenturls[$entryName])?$differenturls[$entryName]:"http://{$entryName}.z.ntaxa.com/";
            }
    }

ksort($dirs);

foreach ($dirs as $k=>$v)
    echo "<div><a href=\"$v\">$k</div>";


closedir($myDirectory);
exit;
?>