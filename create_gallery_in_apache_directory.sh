#!/bin/bash

# this script create nice directory listing for images (with thumbnails)

# example (how to use without download)
# curl https://raw.githubusercontent.com/kakabomba/nicescripts/master/create_gallery_in_apache_directory.sh | bash /dev/stdin -s 100 -a
# you need imagemagick to create thumbnails (apt-get update; apt-get install imagemagick)

usage() { echo "Usage: $0 [-s <int=200>] [-d <string=.gallery>] [-a]
  -s for thumbnail size (default 200)
  -d for directory of thumbnails (and optionaly archive file) (default .gallery)
  -a created archive with all files" 1>&2; exit 1; }

s='200'
d='.gallery'

while getopts "s:d:a" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            ((s >= 1)) || usage
            ;;
        d)
            d=${OPTARG}
            ;;
        a)
            a='all_files.tar.gz'
            ;;
        *)
            usage
            ;;
    esac
done

echo "Creating directory $d"
mkdir $d


if [ "$a" != "" ]; then
  echo "Creating full archive $d/$a"
  tar -czf $d/$a *.gif *.GIF *.JPG *.jpg *.JPEG *.jpeg 
  a="<h2><a href="$d/$a">Download all files</a></h2>"
fi

echo "Writing .htaccess"
cat > .htaccess <<_EOF_
Options +Indexes 
IndexOptions XHTML IgnoreCase
HeaderName $d/header.html
IndexIgnore .??* *.html 

RewriteEngine On
RewriteCond %{QUERY_STRING} ^thumbnail\$
RewriteRule ^(.*(JPG|gif|GIF|JPG|jpg|JPEG|jpeg))\$ $d/\$1? [L,NC]
_EOF_

echo "Writing $d/.htaccess"
cat > $d/.htaccess <<_EOF_
Options -Indexes 

RewriteEngine Off
_EOF_

echo "Writing $d/header.html"
cat > $d/header.html <<_EOF_
<script type="text/javascript">
var list;
var images;

window.onload = function()
{
 list = document.getElementsByTagName('ul')[0];
 images = document.getElementsByTagName('li');
 
 for(var i=1; i<images.length; i++)
 {
  var thumb = images[i].firstChild.cloneNode(true);
  thumb.innerHTML = '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" a="' + thumb.href.replace(/^about:/gi, '') + '?thumbnail" alt="' + thumb.href + '" style="width:${s}px; height:${s}px; background-size: contain; background-repeat: no-repeat;  background-position: center center; background-image: url('+thumb.href.replace(/^about:/gi, '') +'?thumbnail)  "/>';
  with(thumb.style)
  {
   width = '${s}px';
   height = '${s}px';
   display = 'block';
   cssFloat = 'left';
   border = '#ccc 1px solid';
   margin = '2px';
   padding = '2px';
   textAlign = 'center';
  }
  list.parentNode.appendChild(thumb);
 }
 list.style.display = 'none';
}
</script>
$a
_EOF_

echo "Creating thumbnails with sizr $s"
for i in *.gif *.GIF *.JPG *.jpg *.JPEG *.jpeg
  do               
  echo "Prcoessing image $i ..."
  /usr/bin/convert -resize $sx$s $i $d/$i
done

