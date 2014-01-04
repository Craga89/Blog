#!/bin/bash
##############################################
# modified version of original http://media-glass.es/ghost-sitemaps/
# for ghost.centminmod.com
# http://ghost.centminmod.com/ghost-sitemap-generator/
##############################################
url="blog.craigsworks.com"
webroot='/var/www/blog/public'
path="${webroot}/sitemap.xml"
user='www-data'		# web server user
group='www-data'	# web server group
 
debug='n' # disable debug mode with debug='n'
##############################################
date=`date +'%FT%k:%M:%S+00:00'`
freq="daily"
prio="0.5"
reject='.rss,.gif,.png,.jpg,.css,.js,.txt,.ico,.eot,.woff,.ttf,.svg,.txt'
##############################################
# create sitemap.xml file if it doesn't exist and give it same permissions
# as nginx server user/group
if [[ ! -f "$path" ]]; then
	touch $path
	chown ${user}:${group} $path
fi
 
# check for robots.txt defined Sitemap directive
# if doesn't exist add one
# https://support.google.com/webmasters/answer/183669
if [ -f "${webroot}/robots.txt" ]; then
SITEMAPCHECK=$(grep 'Sitemap:' ${webroot}/robots.txt)
	if [ -z "$SITEMAPCHECK" ]; then
	echo "Sitemap: http://${url}/sitemap.xml" >> ${webroot}/robots.txt
	fi
fi
##############################################
echo "" > $path
 
# grab list of site urls
list=`wget -r --delete-after $url --reject=${reject} 2>&1 |grep "\-\-"  |grep http | grep -v 'normalize\.css' | awk '{ print $3 }'`
 
if [[ "$debug" = [yY] ]]; then
	echo "------------------------------------------------------"
	echo "Following list of urls will be submitted to Google"
	echo $list
	echo "------------------------------------------------------"
fi
 
# put list into an array
array=($list)
 
echo "------------------------------------------------------"
echo ${#array[@]} "pages detected for $url" 
echo "------------------------------------------------------"
 
# formatted properly according to
# https://support.google.com/webmasters/answer/35738
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9 
http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" > $path
 
echo ' 
   ' >> $path;
   for ((i=0;i<${#array[*]};i++)); do
echo "<url>
    <loc>${array[$i]:0}</loc>
    <lastmod>$date</lastmod>
    <changefreq>$freq</changefreq>
    <priority>$prio</priority>
</url>" >> $path
   done
echo "" >> $path
echo "</urlset>" >> $path
 
# notify google
# URL encode urls as per https://support.google.com/webmasters/answer/183669
if [[ "$debug" = [nN] ]]; then
	wget  -q --delete-after http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2F${url}%2Fsitemap.xml
 
	rm -rf ${url}
else
	echo "wget  -q --delete-after http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2F${url}%2Fsitemap.xml"
 
	echo "rm -rf ${url}"
fi
echo "------------------------------------------------------"
 
exit 0
