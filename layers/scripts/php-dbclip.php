<?php
   $dbhost = 'mysql.us-east-1.rds.amazonaws.com:3036';
   $dbuser = 'dbadmin';
   $dbpass = 'randomssm';
   
   $conn = mysql_connect($dbhost, $dbuser, $dbpass);
   
   if(! $conn ) {
      die('Could not connect: ' . mysql_error());
   }
   
   $sql = 'SELECT name, owner, species, sex FROM employee';
   mysql_select_db('store');
   $retval = mysql_query( $sql, $conn );
   
   if(! $retval ) {
      die('Could not get data: ' . mysql_error());
   }
   
   while($row = mysql_fetch_array($retval, MYSQL_ASSOC)) {
      echo "PET NAME :{$row['name']}  <br> ".
           "PET OWNER : {$row['owner']} <br> ".
           "PET SPECIES : {$row['species']} <br> ".
           "PET SEX: {$row['sex']} <br>".
	   "--------------------------------<br>";
   }
   
   echo "Fetched data successfully\n";
   
   mysql_close($conn);
?>
