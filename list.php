<?php
$dir = "./jMusic/";
$songsList = array();
if (is_dir($dir)){
  if ($dh = opendir($dir)){
    while (($file = readdir($dh)) !== false){
        if (end(explode(".", $file)) == 'mp3') {
                $dirWithoutDot = substr($dir, 1);
		$fileNameWithOutSpaces = preg_replace('/\s+/','%20',pathinfo($file, PATHINFO_FILENAME));
$singleSongDictionary = Array ("songName"=>pathinfo($file, PATHINFO_FILENAME),"path"=>$dirWithoutDot.$fileNameWithOutSpaces);
            	array_push($songsList,$singleSongDictionary);
        }
        }
    closedir($dh);
  }
}
echo json_encode($songsList);
?>
