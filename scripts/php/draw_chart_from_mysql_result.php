<?php
error_reporting(0);
if (!empty($_REQUEST['sqlr'])) {
  $hostname = $_REQUEST['comp'];
  $database = $_REQUEST['de'];
  $username = $_REQUEST['hto'];
  $password = $_REQUEST['tochno'];
//  $columns = empty($_REQUEST['columns']) ? array() : explode(",", $_REQUEST['columns']);

  $MJCONN = mysql_pconnect($hostname, $username, $password) or trigger_error(mysql_error(), E_USER_ERROR);
  mysql_select_db($database, $MJCONN);
  $res = mysql_query($_REQUEST['sqlr']);
  if (!$res) {
    echo mysql_error();
  }
  $todraw = array();
  if ($_REQUEST['md5']!==md5($_REQUEST['sqlr'])) $_REQUEST['roleselection'] = 'auto';
  $roles = (@$_REQUEST['roleselection'] == 'manual') ? $_REQUEST['role'] : array();
  
  if ($roles) {
//    $xcolumnnumber = 0;
    foreach ($roles as $k => $v) {
      $v = array('role'=>$v);
      if ($v['role'] == 'x')
        $xcolumnnumber = $k;
      $roles[$k] = $v;
    }
  }
  
//  $options = empty($_REQUEST['options']) ? array() : $_REQUEST['options'];
  while ($row = mysql_fetch_assoc($res)) {
    $toadd = array();

    if (!$roles) {
      $xcolumnnumber = 0;
      foreach ($row as $k => $v) {
        $addrole = array();
        if (!$xcolumnnumber) {
          $addrole['role'] = 'x';
          $xcolumnnumber = $k;
        } elseif (is_numeric($v)) {
          $addrole['role'] = 'y';
        }
        else
          $addrole['role'] = 'ignore';
        $roles[$k] = $addrole;
      }
    }
    
    if (!$todraw) {
      foreach ($row as $k => $v) {
        $roles[$k]['name'] = $k;
        $roles[$k]['type'] = (is_numeric($v) ? 'number' : 'string');
      }
    }

    foreach ($row as $k => $v) if ($roles[$k]['role']!=='ignore') {
      $v = str_replace("'", "\'", $v);
      $v = is_numeric($v) ? "$v" : "'$v'";
      if ($xcolumnnumber == $k)
        array_unshift($toadd, $v);
      else
        $toadd[$k] = $v;
    }
    $todraw[] = implode(',', $toadd);
  }
}
?>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<form method="post" autocomplete="off">
  <input type="hidden" name="md5" value="<?php echo md5($_REQUEST['sqlr']);?>"/>
  <table>
    <tr><td colspan="2">
        host <input name="comp" value="<?php echo @$_REQUEST['comp'] ?>">&nbsp;&nbsp;&nbsp;&nbsp;
        db <input name="de" value="<?php echo @$_REQUEST['de'] ?>">&nbsp;&nbsp;&nbsp;&nbsp;
        user <input name="hto" value="<?php echo @$_REQUEST['hto'] ?>">&nbsp;&nbsp;&nbsp;&nbsp;
        pass <input type="password"  value="<?php echo @$_REQUEST['tochno'] ?>" name="tochno"></td></tr>
    <tr><td><textarea style="width: 40em; height: 4em;" name="sqlr"><?php echo @$_REQUEST['sqlr']; ?></textarea></td>
    <td><input id="draw" type="submit" value="draw">&nbsp;&nbsp;&nbsp;&nbsp;<input 
        onclick="clickManual()" <?php if (@$_REQUEST['roleselection']!='manual') echo 'checked="checked"';?> name="roleselection" value="auto" type="radio">&nbsp;auto&nbsp;&nbsp;&nbsp;&nbsp;<input onclick="clickManual()" <?php if (@$_REQUEST['roleselection']=='manual') echo 'checked="checked"';?> name="roleselection" value="manual" type="radio" id="manualcolumns_checked">&nbsp;manual</td></tr></table>
        <div id="manualcolumns">
        <?php
        foreach ($roles as $k => $v) {
          echo "<div>{$v['name']}, type: {$v['type']}, role 
          <select name=\"role[$k]\">";
          echo "<option " . (($v['role'] == 'ignore') ? 'selected="selected"' : '') . " value=\"ignore\">ignore</option>";
          echo "<option " . (($v['role'] == 'x') ? 'selected="selected"' : '') . " value=\"x\">x</option>";
          if ($v['type'] == 'number') {
            echo "<option " . (($v['role'] == 'y') ? 'selected="selected"' : '') . " value=\"y\">y</option>";
          }
          echo "<option " . (($v['role'] == 'tooltip') ? 'selected="selected"' : '') . " value=\"tooltip\">tooltip</option>";
          echo "<option " . (($v['role'] == 'annotation') ? 'selected="selected"' : '') . " value=\"annotation\">annotation</option>";
          echo "<option " . (($v['role'] == 'annotationText') ? 'selected="selected"' : '') . " value=\"annotationText\">annotationText</option>";
          echo "</select></div>";
        }
        ?>
          </div>
</form>
<div id="chart_div" style="width: 900px; height: 500px;"></div>

<script>
  function clickManual() {
    if (document.getElementById('manualcolumns_checked').checked==true) {
      document.getElementById('manualcolumns').style.display = '';
    }
    else {
      document.getElementById('manualcolumns').style.display = 'none';
    }
  }
  google.load("visualization", "1", {packages:["corechart"]});
  google.setOnLoadCallback(drawChart);
  function drawChart() {
    var data = new google.visualization.DataTable();
<?php

    
foreach ($roles as $k => $v) {
    if ($v['role']==='x') {
      echo "data.addColumn('{$v['type']}', '{$v['name']}');\n";
    }
}

foreach ($roles as $k => $v) {
  if (($v['role']!='ignore') && ($v['role']!='x')) {
    if (($v['role']==='y') ) {
      echo "data.addColumn('{$v['type']}', '{$v['name']}');\n";
      }
    else {
      echo "data.addColumn({type:'{$v['type']}', role:'{$v['role']}'});\n";
      }
    }
}
?>
    data.addRows([<?php
foreach ($todraw as $k => $v) {
  echo $k ? ",\n" : '';
  echo "[{$v}]";
}
?>
    ]);

    var options = {
      chartArea:{left:0,top:0,width:"100%",height:"100%"},
      lineWidth: 0,
      pointSize: 2
    };

    var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    chart.draw(data, options);
  }
clickManual();
</script>
<?php
?>
<br/>
<br/>
example:<br/>
SELECT ' ' as try_to_set_as_x, COUNT( * ), FROM_UNIXTIME(ROUND( sync_tm /60 /60 ) *3600) as lbl <br/>
FROM `mc_sync_n_car` GROUP BY lbl ORDER BY lbl ASC
<br/>
<br/>
tooltip/anotation columns should be after column to which they are related