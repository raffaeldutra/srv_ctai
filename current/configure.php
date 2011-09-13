<?php

include_once "/usr/share/php-geshi/geshi.php";

if ($_GET['lang'] == "")
{
    $_GET['lang'] = "bash";
}

if ($_GET['file'] == "")
{
    $_GET['file'] = "setEnvironment.sh";
}

$geshi = new GeSHi(file_get_contents($_GET['file'], FILE_USE_INCLUDE_PATH), $_GET['lang']);

echo $geshi->parse_code();

?>
