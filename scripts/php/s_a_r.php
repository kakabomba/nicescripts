<form method="post">
<table>
    <tr><td>host</td><td><input name="comp" value="<?php echo @$_REQUEST['comp']?>"></td></tr>
<tr><td>db</td><td><input name="de" value="<?php echo @$_REQUEST['de']?>"></td></tr>
<tr><td>user</td><td><input name="hto" value="<?php echo @$_REQUEST['hto']?>"></td></tr>
<tr><td>pass</td><td><input type="password" name="tochno"></td></tr>
<tr><td>search</td><td><input name="ws" value="<?php echo @$_REQUEST['ws']?>"></td></tr>
<tr><td>s/r</td><td>
        <input id="qt_search" onclick="setQT()" type="radio" <?php ?> checked="checked" name="qt" value="search"><label  onclick="setQT()" for="qt_search">search</label>
        <input id="qt_replace" onclick="setQT()" type="radio" name="qt" value="replace"><label for="qt_replace"  onclick="setQT()">replace</label>
    </td></tr>
<tr><td>replace</td><td><input id="wr" name="wr" value="<?php echo @$_REQUEST['wr']?>"></td></tr>
<tr><td colspan="2" align="right"><input id="sb" type="submit" value="search"></td></tr>
</table>
</form>
<script>
    function  setQT() {
        if (document.getElementById('qt_search').checked) {
            document.getElementById('wr').disabled = true;
            document.getElementById('sb').value = 'search';
            }
        else {
            document.getElementById('wr').disabled = false;
            document.getElementById('sb').value = 'replace';
        }
        }
setQT();
</script>
<?php
// Find and replace facility for complete MySQL database
//
// Written by Mark Jackson @ MJDIGITAL
// Can be used by anyone - but give me a nod if you do!
// http://www.mjdigital.co.uk/blog

error_reporting(0);
if (!empty($_REQUEST['qt'])) {
// SEARCH FOR
$search        = $_REQUEST['ws'];

// REPLACE WITH
$replace    = @$_REQUEST['wr']; // (used if queryType below is set to 'replace')

// DB Details
$hostname = $_REQUEST['comp'];
$database = $_REQUEST['de'];
$username = $_REQUEST['hto'];
$password = $_REQUEST['tochno'];

// Query Type: 'search' or 'replace'
$queryType = $_REQUEST['qt'];

// show errors (.ini file dependant) - true/false
$showErrors = true;

//////////////////////////////////////////////////////
//
//        DO NOT EDIT BELOW
//
//////////////////////////////////////////////////////

if($showErrors) {
    error_reporting(E_ALL);
    ini_set('error_reporting', E_ALL);
    ini_set('display_errors',1);
}

// Create connectio to DB
$MJCONN = mysql_pconnect($hostname, $username, $password) or trigger_error(mysql_error(),E_USER_ERROR);
mysql_select_db($database,$MJCONN);

// Get list of tables
$table_sql = 'SHOW TABLES';
$table_q = mysql_query($table_sql,$MJCONN) or die("Cannot Query DB: ".mysql_error());
$tables_r = mysql_fetch_assoc($table_q);
$tables = array();

do{
    $tables[] = $tables_r['Tables_in_'.strtolower($database)];
}while($tables_r = mysql_fetch_assoc($table_q));

// create array to hold required SQL
$use_sql = array();

$rowHeading = ($queryType=='replace') ? 
        'Replacing \''.$search.'\' with \''.$replace.'\' in \''.$database."'\n\nSTATUS    |    ROWS AFFECTED    |    TABLE/FIELD    (+ERROR)\n"
      : 'Searching for \''.$search.'\' in \''.$database."'\n\nSTATUS    |    ROWS CONTAINING    |    TABLE/FIELD    (+ERROR)\n";

$output = $rowHeading;

$summary = '';

// LOOP THROUGH EACH TABLE
foreach($tables as $table) {
    // GET A LIST OF FIELDS
    $field_sql = 'SHOW FIELDS FROM '.$table;
    $field_q = mysql_query($field_sql,$MJCONN);
    $field_r = mysql_fetch_assoc($field_q);

    // compile + run SQL
    do {
        $field = $field_r['Field'];
        $type = $field_r['Type'];

        switch(true) {
            // set which column types can be replaced/searched
            case stristr(strtolower($type),'char'): $typeOK = true; break;
            case stristr(strtolower($type),'text'): $typeOK = true; break;
            case stristr(strtolower($type),'blob'): $typeOK = true; break;
            case stristr(strtolower($field_r['Key']),'pri'): $typeOK = false; break; // do not replace on primary keys
            default: $typeOK = false; break;
        }

        if($typeOK) { // Field type is OK ro replacement
            // create unique handle for update_sql array
            $handle = $table.'_'.$field;
            if($queryType=='replace') {
                $sql[$handle]['sql'] = 'UPDATE `'.$table.'` SET `'.$field.'` = REPLACE(`'.$field.'`,\''.$search.'\',\''.$replace.'\')';
            } else {
                $sql[$handle]['sql'] = 'SELECT * FROM `'.$table.'` WHERE `'.$field.'` REGEXP(\''.$search.'\')';
            }

            // execute SQL
            $error = false;
            $query = @mysql_query($sql[$handle]['sql'],$MJCONN) or $error = mysql_error();
            $row_count = @mysql_affected_rows() or $row_count = 0;

            // store the output (just in case)
            $sql[$handle]['result'] = $query;
            $sql[$handle]['affected'] = $row_count;
            $sql[$handle]['error'] = $error;

            // Write out Results into $output
            $output .= ($query) ? 'OK        ' : '--        ';
            $output .= ($row_count>0) ? '<strong>'.$row_count.'</strong>            ' : '<span style="color:#CCC">'.$row_count.'</span>            ';
            $fieldName = '`'.$table.'`.`'.$field.'`';
            $output .= $fieldName;
            $erTab = str_repeat(' ', (160-strlen($fieldName)) );
            $output .= ($error) ? $erTab.'(ERROR: '.$error.')' : '';

            $output .= "\n";
        }
    }while($field_r = mysql_fetch_assoc($field_q));
}

// write the output out to the page
echo '<pre>';
echo $output."\n";
echo '<pre>';
}
?>