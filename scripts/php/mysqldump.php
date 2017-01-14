<?php
namespace Clouddueling\Mysqldump;

use Exception;
use PDO;
use PDOException;

//$tables = (isset($_POST['tables'])?$_POST['tables']:'*');
$host = (isset($_POST['host'])?$_POST['host']:'localhost');
$user = (isset($_POST['user'])?$_POST['user']:'root');
$db = (isset($_POST['db'])?$_POST['db']:'');
$password = (isset($_POST['password'])?$_POST['password']:'');
$savedir = (isset($_POST['savedir'])?$_POST['savedir']:'./');
$download = (isset($_POST['download'])?($_POST['download']?true:false):true);

$include_tables = ((!isset($_POST['include_tables']) || ''===trim($_POST['include_tables']))?array('*'):preg_split('/[\w]*,[\w]*/',trim($_POST['include_tables'])));
$exclude_tables = ((!isset($_POST['exclude_tables']) || ''===trim($_POST['exclude_tables']))?array():preg_split('/[\w]*,[\w]*/',trim($_POST['exclude_tables'])));
$no_data = (isset($_POST['no_data'])?($_POST['no_data']?true:false):false);
$compress = (isset($_POST['compress'])?(in_array($_POST['compress'],array('GZIP', 'BZIP2', 'NONE'))?$_POST['compress']:'GZIP'):'GZIP');
$add_drop_database = (isset($_POST['add_drop_database'])?($_POST['add_drop_database']?true:false):false);
$add_drop_table = (isset($_POST['add_drop_table'])?($_POST['add_drop_table']?true:false):true);
$single_transaction = (isset($_POST['single_transaction'])?($_POST['single_transaction']?true:false):true);
$lock_tables = (isset($_POST['lock_tables'])?($_POST['lock_tables']?true:false):false);
$add_locks = (isset($_POST['add_locks'])?($_POST['add_locks']?true:false):true);
$extended_insert = (isset($_POST['extended_insert'])?($_POST['extended_insert']?true:false):true);
$disable_foreign_keys_check = (isset($_POST['disable_foreign_keys_check'])?($_POST['disable_foreign_keys_check']?true:false):true);

//var_dump($_POST);
//var_dump($single_transaction);

$dumpSettings = array(
        'include-tables' => $include_tables,
        'exclude-tables' => $exclude_tables,
        'compress' => 'GZIP',
        'no-data' => $no_data,
        'add-drop-database' => $add_drop_database,
        'add-drop-table' => $add_drop_table,
        'single-transaction' => $single_transaction,
        'lock-tables' => $lock_tables,
        'add-locks' => $add_locks,
        'extended-insert' => $extended_insert,
        'disable-foreign-keys-check' => $disable_foreign_keys_check );

if (implode(',',$include_tables) === '*') {
  unset($dumpSettings['include-tables']);
}

//var_dump($dumpSettings);

if (empty($_POST)) {
  ?>
  <form method="post" action="">
    <table style="width: 1%; table-layout: auto">
      <tr><td style="width: 1%; white-space: nowrap;">host[:port]: </td><td style="width: 99%; white-space: nowrap;"><input name="host" value="<?php echo $host;?>" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">user: </td><td style="width: 99%; white-space: nowrap;"><input name="user" value="<?php echo $user;?>" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">password: </td><td style="width: 99%; white-space: nowrap;"><input name="password" value="<?php echo $password;?>" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">db: </td><td style="width: 99%; white-space: nowrap;"><input name="db" value="<?php echo $db;?>" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">compress: </td><td style="width: 99%; white-space: nowrap;">
          <input type="radio" <?php if ($compress === 'GZIP') echo 'checked="checked"'; ?> name="compress" value="GZIP" />gzip
          <input type="radio" <?php if ($compress === 'BZIP2') echo 'checked="checked"'; ?> name="compress" value="BZIP2" />bzip2
          <input type="radio" <?php if ($compress === 'NONE') echo 'checked="checked"'; ?> name="compress" value="NONE" />none
        </td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">include tables: </td><td style="width: 99%; white-space: nowrap;"><input name="include_tables" value="<?php echo implode(',',$include_tables);?>" />(comma separated, * for all)</td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">exclude tables: </td><td style="width: 99%; white-space: nowrap;"><input name="exclude_tables" value="<?php echo implode(',',$exclude_tables);?>" />(comma separated, blank for none)</td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">drop database: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="add_drop_database" value="0" /><input type="checkbox" <?php if ($add_drop_database) echo 'checked="checked"'; ?> name="add_drop_database" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">drop table: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="add_drop_table" value="0" /><input type="checkbox" <?php if ($add_drop_table) echo 'checked="checked"'; ?> name="add_drop_table" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">single transaction: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="single_transaction" value="0" /><input type="checkbox" <?php if ($single_transaction) echo 'checked="checked"'; ?> name="single_transaction" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">lock tables: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="lock_tables" value="0" /><input type="checkbox" <?php if ($lock_tables) echo 'checked="checked"'; ?> name="lock_tables" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">add locks: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="add_lock" value="0" /><input type="checkbox" <?php if ($add_locks) echo 'checked="checked"'; ?> name="add_locks" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">extended insert: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="extended_insert" value="0" /><input type="checkbox" <?php if ($extended_insert) echo 'checked="checked"'; ?> name="extended_insert" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">no foreign keys check: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="disable_foreign_keys_check" value="0" /><input type="checkbox" <?php if ($disable_foreign_keys_check) echo 'checked="checked"'; ?> name="disable_foreign_keys_check" value="1" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">download: </td><td style="width: 99%; white-space: nowrap;"><input type="hidden" name="download" value="0" /><input type="checkbox" <?php if ($download) echo 'checked="checked"'; ?> name="download" value="1" />(file will be removed from server)</td></tr>
      <tr><td style="width: 1%; white-space: nowrap;">save to directory: </td><td style="width: 99%; white-space: nowrap;"><input name="savedir" value="<?php echo $savedir;?>" /></td></tr>
      <tr><td style="width: 1%; white-space: nowrap;"></td><td style="width: 99%; white-space: nowrap; text-align: right;"><input type="submit"/></td></tr>
    </table>
  </form>
  <?php
  exit;
}





class Mysqldump
{
    const MAXLINESIZE = 1000000;

    // This can be set both on constructor or manually
    public $host;
    public $user;
    public $pass;
    public $db;
    public $fileName = 'dump.sql';

    // Internal stuff
    private $_settings = array();
    private $_tables = array();
    private $_views = array();
    private $_dbHandler;
    private $_dbType;
    private $_compressManager;
    private $_typeAdapter;
    private $_pdoOptions;

    /**
     * Constructor of Mysqldump. Note that in the case of an SQLite database
     * connection, the filename must be in the $db parameter.
     *
     * @param string $db        Database name
     * @param string $user      SQL account username
     * @param string $pass      SQL account password
     * @param string $host      SQL server to connect to
     * @param string $type      SQL database type
     * @return null
     */
    public function __construct($db = '', $user = '', $pass = '',
        $host = 'localhost', $type = "mysql", $settings = null,
        $pdoOptions = array(PDO::ATTR_PERSISTENT => true,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"))
    {
        $defaultSettings = array(
            'include-tables' => array(),
            'exclude-tables' => array(),
            'compress' => 'None',
            'no-data' => false,
            'add-drop-database' => false,
            'add-drop-table' => false,
            'single-transaction' => true,
            'lock-tables' => false,
            'add-locks' => true,
            'extended-insert' => true,
            'disable-foreign-keys-check' => false
        );

        $this->db = $db;
        $this->user = $user;
        $this->pass = $pass;
        $this->host = $host;
        $this->_dbType = strtolower($type);
        $this->_pdoOptions = $pdoOptions;
        $this->_settings = Mysqldump::array_replace_recursive($defaultSettings, $settings);
    }

    /**
     * Custom array_replace_recursive to be used if PHP < 5.3
     *
     * @return array
     */
    public static function array_replace_recursive($array1, $array2)
    {
        if ( function_exists('array_replace_recursive') ) {
            return array_replace_recursive($array1, $array2);
        } else {
            foreach ($array2 as $key => $value) {
                if (is_array($value)) {
                    $array1[$key] = Mysqldump::array_replace_recursive($array1[$key], $value);
                } else {
                    $array1[$key] = $value;
                }
            }
            return $array1;
        }
    }

    /**
     * Connect with PDO
     *
     * @return bool
     */
    private function connect()
    {

        // Connecting with PDO
        try {
            switch ($this->_dbType) {
                case 'sqlite':
                    $this->_dbHandler = new PDO("sqlite:" . $this->db, null, null, $this->_pdoOptions);
                    break;
                case 'mysql': case 'pgsql': case 'dblib':
                    $this->_dbHandler = new PDO(
                        $this->_dbType . ":host=" .
                        $this->host.";dbname=" . $this->db, $this->user,
                        $this->pass, $this->_pdoOptions
                    );
                    // Fix for always-unicode output
                    $this->_dbHandler->exec("SET NAMES utf8");
                    break;
                default:
                    throw new Exception("Unsupported database type (" . $this->_dbType . ")", 3);
            }
        } catch (PDOException $e) {
            throw new Exception(
                "Connection to " . $this->_dbType . " failed with message: " .
                $e->getMessage(), 3
            );
        }

        $this->_dbHandler->setAttribute(PDO::ATTR_ORACLE_NULLS, PDO::NULL_NATURAL);
        $this->_typeAdapter = TypeAdapterFactory::create($this->_dbType);
    }

    /**
     * Main call
     *
     * @param string $filename  Name of file to write sql dump to
     * @return bool
     */
    public function start($filename = '')
    {
        // Output file can be redefined here
        if ( !empty($filename) ) {
            $this->fileName = $filename;
        }
        // We must set a name to continue
        if ( empty($this->fileName) ) {
            throw new Exception("Output file name is not set", 1);
        }

        // Connect to database
        $this->connect();

        // Create a new compressManager to manage compressed output
        $this->_compressManager = CompressManagerFactory::create($this->_settings['compress']);

        if (! $this->_compressManager->open($this->fileName)) {
            throw new Exception("Output file is not writable", 2);
        }

        // Formating dump file
        $this->_compressManager->write($this->getHeader());

        if ( $this->_settings['add-drop-database'] ) {
            $this->_compressManager->write($this->_typeAdapter->add_drop_database($this->db, $this->_dbHandler));
        }

        // Listing all tables from database
        $this->_tables = array();
        foreach ($this->_dbHandler->query($this->_typeAdapter->show_tables($this->db)) as $row) {
            if ( empty($this->_settings['include-tables']) ||
                (! empty($this->_settings['include-tables']) &&
                in_array(current($row), $this->_settings['include-tables'], true))) {
                array_push($this->_tables, current($row));
                // remove tables from include-tables array.
                if ( ($key = array_search(current($row), $this->_settings['include-tables'])) !== false ) {
                    unset($this->_settings['include-tables'][$key]);
                }
            }
        }

        // If there still are some tables in include-tables array, that means
        // that some tables weren't found. Give proper error and exit.
        if ( 0 < count($this->_settings['include-tables']) ) {
            throw new Exception("Table (" . implode(",", $this->_settings['include-tables']) . ") not found in database", 4);
        }

        // Disable checking foreign keys
        if ( $this->_settings['disable-foreign-keys-check'] ) {
            $this->_compressManager->write(
                $this->_typeAdapter->start_disable_foreign_keys_check()
            );
        }

        // Exporting tables one by one
        foreach ($this->_tables as $table) {
            if (in_array($table, $this->_settings['exclude-tables'], true)) {
                continue;
            }
            $is_table = $this->getTableStructure($table);
            if (true === $is_table && false === $this->_settings['no-data']) {
                $this->listValues($table);
            }
        }

        // Exporting views one by one
        foreach ($this->_views as $view) {
            $this->_compressManager->write($view);
        }

        // Enable checking foreign keys if needed
        if ( $this->_settings['disable-foreign-keys-check'] ) {
            $this->_compressManager->write(
                $this->_typeAdapter->end_disable_foreign_keys_check()
            );
        }

        $this->_compressManager->close();
    }

    /**
     * Returns header for dump file
     *
     * @return null
     */
    private function getHeader()
    {
        // Some info about software, source and time
        $header = "-- sqldump-php SQL Dump\n" .
                "-- https://github.com/clouddueling/mysqldump-php\n" .
                "--\n" .
                "-- Host: {$this->host}\n" .
                "-- Generation Time: " . date('r') . "\n\n" .
                "--\n" .
                "-- Database: `{$this->db}`\n" .
                "--\n\n";

        return $header;
    }

    /**
     * Table structure extractor
     *
     * @param string $tablename  Name of table to export
     * @return null
     */
    private function getTableStructure($tablename)
    {
        $stmt = $this->_typeAdapter->show_create_table($tablename);
        foreach ($this->_dbHandler->query($stmt) as $r) {
            if (isset($r['Create Table'])) {
                $this->_compressManager->write(
                    "-- --------------------------------------------------------" .
                    "\n\n" .
                    "--\n" .
                    "-- Table structure for table `$tablename`\n" .
                    "--\n\n"
                );

                if ($this->_settings['add-drop-table']) {
                    $this->_compressManager->write("DROP TABLE IF EXISTS `$tablename`;\n\n");
                }
                $this->_compressManager->write($r['Create Table'] . ";\n\n");
                return true;
            }

            if ( isset($r['Create View']) ) {
                $view  = "-- --------------------------------------------------------" .
                        "\n\n" .
                        "--\n" .
                        "-- Table structure for view `$tablename`\n" .
                        "--\n\n";
                $view .= $r['Create View'] . ";\n\n";
                $this->_views[] = $view;
                return false;
            }
        }
    }

    /**
     * Table rows extractor
     *
     * @param string $tablename  Name of table to export
     * @return null
     */
    private function listValues($tablename)
    {
        $this->_compressManager->write(
            "--\n" .
            "-- Dumping data for table `$tablename`\n" .
            "--\n\n"
        );

        if ( $this->_settings['single-transaction'] ) {
            $this->_dbHandler->exec($this->_typeAdapter->start_transaction());
        }

        if ( $this->_settings['lock-tables'] ) {
            $lockstmt = $this->_typeAdapter->lock_table($tablename);
            if ( strlen($lockstmt) ) {
                $this->_dbHandler->exec($lockstmt);
            }
        }

        if ( $this->_settings['add-locks'] ) {
            $this->_compressManager->write($this->_typeAdapter->start_add_lock_table($tablename));
        }

        $onlyOnce = true; $lineSize = 0;
        $stmt = "SELECT * FROM `$tablename`";
        foreach ($this->_dbHandler->query($stmt, PDO::FETCH_NUM) as $r) {
            $vals = array();
            foreach ($r as $val) {
                $vals[] = is_null($val) ? "NULL" :
                $this->_dbHandler->quote($val);
            }
            if ($onlyOnce || !$this->_settings['extended-insert'] ) {
                $lineSize += $this->_compressManager->write(
                    "INSERT INTO `$tablename` VALUES (" . implode(",", $vals) . ")"
                );
                $onlyOnce = false;
            } else {
                $lineSize += $this->_compressManager->write(",(" . implode(",", $vals) . ")");
            }
            if ( ($lineSize > Mysqldump::MAXLINESIZE) ||
                    !$this->_settings['extended-insert'] ) {
                $onlyOnce = true;
                $lineSize = $this->_compressManager->write(";\n");
            }
        }

        if ( !$onlyOnce ) {
            $this->_compressManager->write(";\n");
        }

        if ( $this->_settings['add-locks'] ) {
            $this->_compressManager->write($this->_typeAdapter->end_add_lock_table($tablename));
        }

        if ( $this->_settings['single-transaction'] ) {
            $this->_dbHandler->exec($this->_typeAdapter->commit_transaction());
        }

        if ( $this->_settings['lock-tables'] ) {
            $lockstmt = $this->_typeAdapter->unlock_table($tablename);
            if ( strlen($lockstmt) ) {
                $this->_dbHandler->exec($lockstmt);
            }
        }
    }
}

/**
 * Enum with all available compression methods
 *
 */
abstract class CompressMethod
{
    public static $enums = array(
        "None",
        "Gzip",
        "Bzip2"
    );

    public static function isValid($c)
    {
        return in_array($c, self::$enums);
    }
}

abstract class CompressManagerFactory
{
    private $_fileHandle = null;

    public static function create($c)
    {
        $c = ucfirst(strtolower($c));
        if (! CompressMethod::isValid($c)) {
            throw new Exception("Compression method ($c) is not defined yet", 1);
        }

        $method =  __NAMESPACE__ . "\\" . "Compress" . $c;

        return new $method;
    }
}

class CompressBzip2 extends CompressManagerFactory
{
    public function __construct()
    {
        if (! function_exists("bzopen")) {
            throw new Exception("Compression is enabled, but bzip2 lib is not installed or configured properly", 1);
        }
    }

    public function open($filename)
    {
        $this->_fileHandler = bzopen($filename . ".bz2", "w");
        if (false === $this->_fileHandler) {
            return false;
        }

        return true;
    }

    public function write($str)
    {
        $bytesWritten = 0;
        if (false === ($bytesWritten = bzwrite($this->_fileHandler, $str))) {
            throw new Exception("Writting to file failed! Probably, there is no more free space left?", 4);
        }

        return $bytesWritten;
    }

    public function close()
    {
        return bzclose($this->_fileHandler);
    }
}

class CompressGzip extends CompressManagerFactory
{
    public function __construct()
    {
        if (! function_exists("gzopen") ) {
            throw new Exception("Compression is enabled, but gzip lib is not installed or configured properly", 1);
        }
    }

    public function open($filename)
    {
        $this->_fileHandler = gzopen($filename . ".gz", "wb");
        if (false === $this->_fileHandler) {
            return false;
        }

        return true;
    }

    public function write($str)
    {
        $bytesWritten = 0;
        if (false === ($bytesWritten = gzwrite($this->_fileHandler, $str))) {
            throw new Exception("Writting to file failed! Probably, there is no more free space left?", 4);
        }

        return $bytesWritten;
    }

    public function close()
    {
        return gzclose($this->_fileHandler);
    }
}

class CompressNone extends CompressManagerFactory
{
    public function open($filename)
    {
        $this->_fileHandler = fopen($filename, "wb");
        if (false === $this->_fileHandler) {
            return false;
        }

        return true;
    }

    public function write($str)
    {
        $bytesWritten = 0;
        if (false === ($bytesWritten = fwrite($this->_fileHandler, $str))) {
            throw new Exception("Writting to file failed! Probably, there is no more free space left?", 4);
        }

        return $bytesWritten;
    }

    public function close()
    {
        return fclose($this->_fileHandler);
    }
}

/**
 * Enum with all available TypeAdapter implementations
 *
 */
abstract class TypeAdapter
{
    public static $enums = array(
        "Sqlite",
        "Mysql"
    );

    public static function isValid($c)
    {
        return in_array($c, self::$enums);
    }
}

/**
 * TypeAdapter Factory
 *
 */
abstract class TypeAdapterFactory
{
    public static function create($c)
    {
        $c = ucfirst(strtolower($c));
        if (! TypeAdapter::isValid($c)) {
            throw new Exception("Database type support for ($c) not yet available", 1);
        }

        $method =  __NAMESPACE__ . "\\" . "TypeAdapter" . $c;
        return new $method;
    }

    public function show_create_table($tablename)
    {
        return "SELECT tbl_name as 'Table', sql as 'Create Table' " .
            "FROM sqlite_master " .
            "WHERE type='table' AND tbl_name='$tablename'";
    }

    public function show_tables()
    {
        return "SELECT tbl_name FROM sqlite_master where type='table'";
    }

    public function start_transaction()
    {
        return "BEGIN EXCLUSIVE";
    }

    public function commit_transaction()
    {
        return "COMMIT";
    }

    public function lock_table()
    {
        return "";
    }

    public function unlock_table()
    {
        return "";
    }

    public function start_add_lock_table()
    {
        return "\n";
    }

    public function end_add_lock_table()
    {
        return "\n";
    }

    public function start_disable_foreign_keys_check()
    {
        return "\n";
    }

    public function end_disable_foreign_keys_check()
    {
        return "\n";
    }

    public function add_drop_database()
    {
        return "\n";
    }
}

class TypeAdapterPgsql extends TypeAdapterFactory
{
}

class TypeAdapterDblib extends TypeAdapterFactory
{
}

class TypeAdapterSqlite extends TypeAdapterFactory
{
}

class TypeAdapterMysql extends TypeAdapterFactory
{
    public function show_create_table($tableName)
    {
        return "SHOW CREATE TABLE `$tableName`";
    }

    public function show_tables()
    {
        if ( func_num_args() != 1 )
            return "";

        $args = func_get_args();
        $dbName = $args[0];

        return "SELECT TABLE_NAME AS tbl_name " .
            "FROM INFORMATION_SCHEMA.TABLES " .
            "WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='$dbName'";
    }

    public function start_transaction()
    {
        return "SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ; " .
            "START TRANSACTION";
    }

    public function commit_transaction()
    {
        return "COMMIT";
    }

    public function lock_table()
    {
        if ( func_num_args() != 1 )
            return "";

        $args = func_get_args();
        $tableName = $args[0];
        return "LOCK TABLES `$tableName` READ LOCAL";
    }

    public function unlock_table()
    {
        return "UNLOCK TABLES";
    }

    public function start_add_lock_table()
    {
        if ( func_num_args() != 1 )
            return "";

        $args = func_get_args();
        $tableName = $args[0];

        return "LOCK TABLES `$tableName` WRITE;\n";
    }

    public function end_add_lock_table()
    {
        return "UNLOCK TABLES;\n";
    }

    public function start_disable_foreign_keys_check()
    {
        return "-- Ignore checking of foreign keys\n" .
            "SET FOREIGN_KEY_CHECKS = 0;\n\n";
    }

    public function end_disable_foreign_keys_check()
    {
        return "\n-- Unignore checking of foreign keys\n" .
            "SET FOREIGN_KEY_CHECKS = 1; \n\n";
    }

    public function add_drop_database()
    {
        $ret = "";
        if ( func_num_args() != 2 )
            return $ret;

        $args = func_get_args();
        $dbName = $args[0];
        $dbHandler = $args[1];

        $ret .= "/*!40000 DROP DATABASE IF EXISTS `" . $dbName . "`*/;\n";

        $rs = $dbHandler->query("SHOW VARIABLES LIKE 'character_set_database';");
        $characterSet = $rs->fetchColumn(1);

        $rs = $dbHandler->query("SHOW VARIABLES LIKE 'collation_database';");
        $collationDb = $rs->fetchColumn(1);

        $ret .= "CREATE DATABASE /*!32312 IF NOT EXISTS*/ `" . $dbName .
            "` /*!40100 DEFAULT CHARACTER SET " . $characterSet .
            " COLLATE " . $collationDb . "*/;\n" .
            "USE `" . $dbName . "`;\n\n";

        return $ret;
    }
}

use Clouddueling\Mysqldump\Mysqldump;
try {


//    $dumpSettings = array(
//        'include-tables' => array('table1', 'table2'),
//        'exclude-tables' => array('table3', 'table4'),
//        'compress' => 'GZIP',
//        'no-data' => false,
//        'add-drop-database' => false,
//        'add-drop-table' => false,
//        'single-transaction' => true,
//        'lock-tables' => false,
//        'add-locks' => true,
//        'extended-insert' => true,
//        'disable-foreign-keys-check' => false );
$file_name = "dump-{$db}-".date("Y_m_d__H_i_s").'.sql';
$full_fn = "{$savedir}{$file_name}";
$dump = new Mysqldump($db, $user, $password, $host, 'mysql', $dumpSettings);
$dump->start($full_fn);


if ($download) {
    header('Content-Description: File Transfer');
    header('Content-Transfer-Encoding: binary');
    
    if ($compress === 'GZIP') {
      $file_name = "{$file_name}.gz";
      header('Content-type: application/gzip');
      }
    elseif ($compress === 'BZIP2') {
      $file_name = "{$file_name}.bzip2";
      header('Content-type: application/bzip2');
      }
    else {
      header('Content-type: application/octet-stream');
      }
    header('Content-Disposition: attachment; filename='.$file_name);
    header('Expires: 0');
    header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
    header('Pragma: public');
    $full_fn = "{$savedir}{$file_name}";
    header('Content-Length: '.filesize($full_fn));
    readfile($full_fn);
    unlink($full_fn);
    }
else {
echo "$full_fn<br/>";
}
}
 catch (Exception $e) {
   echo "ERROR<br/>";
   echo $e->getMessage();
   echo '<pre>';
   print_r($e);
   echo '</pre>';
 }

exit;

backup_tables($host,$user,$password,$db,$tables,$savedir,$download);


/* backup the db OR just a table */
function backup_tables($host,$user,$pass,$name,$tables = '*', $savedir = './', $download = true)
{

$link = mysql_connect($host,$user,$pass);
if (!$link) {
echo "<br/>cant connect to host=`$host` user=`$user` pass=`$pass`";
exit;
}

$seldb = mysql_select_db($name,$link);
if (!$seldb) {
echo "<br/>cant select database `$name`";
exit;
}

//get all of the tables
if($tables == '*')
{
$tables = array();
$result = mysql_query('SHOW TABLES');
while($row = mysql_fetch_row($result))
{
$tables[] = $row[0];
}
}
else
{
$tables = is_array($tables) ? $tables : explode(',',$tables);
}

$file_name = "db-{$name}-".date("Y_m_d__H_i_s").'.sql';

$full_fn = "{$savedir}{$file_name}";

//save file
$handle = fopen($full_fn,'w+');

if (!$handle) {
echo "<br/>cant create file `$full_fn`";
exit;
}

//cycle through
foreach($tables as $table)
{
$result = mysql_query('SELECT * FROM '.$table);
$num_fields = mysql_num_fields($result);

$return= 'DROP TABLE '.$table.';';
$row2 = mysql_fetch_row(mysql_query('SHOW CREATE TABLE '.$table));
$return.= "\n\n".$row2[1].";\n\n";
fwrite($handle,$return);

for ($i = 0; $i < $num_fields; $i++) 
{
while($row = mysql_fetch_row($result))
{
$return.= 'INSERT INTO '.$table.' VALUES(';
for($j=0; $j<$num_fields; $j++) 
{
$row[$j] = addslashes($row[$j]);
$row[$j] = ereg_replace("\n","\\n",$row[$j]);
if (isset($row[$j])) { $return.= '"'.$row[$j].'"' ; } else { $return.= '""'; }
if ($j<($num_fields-1)) { $return.= ','; }
}
$return.= ");\n";
}
}
$return.="\n\n\n";
}



fwrite($handle,$return);
fclose($handle);

if ($download) {
    header('Content-Description: File Transfer');
    header('Content-Transfer-Encoding: binary');
    header('Content-type: application/octet-stream');
    header('Content-Disposition: attachment; filename='.$file_name);
    header('Expires: 0');
    header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
    header('Pragma: public');
    header('Content-Length: '.filesize($full_fn));
    readfile($full_fn);
    unlink($full_fn);
    }
else {
echo "$full_fn<br/>";
}

}

