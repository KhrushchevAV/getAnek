#!/usr/bin/perl -w
#
#  windows 1251 use for regexp !!!
#
# 2009-12-21 оп€ть помен€ли формат html
# 2010-06-30 смена формата. не стало <pre>
# 2013-01-10 оп€ть помен€ли формат. в 1 строку все анекдоты. :-(

use LWP::UserAgent;
use HTTP::Request;
#---
my($url) = 'http://www.anekdot.ru/last/j.html';
my(@html);
my($pr) = 0;
#my($recip) = '<hrushev.av@kubank.ru>, <NetSveta@upb.ru>, <slava@upb.ru>, <zhuravlevaoa@ektb.vtb24.ru>, <root@copy-news.ru>';
my($recip) = '<hrushev.av@kubank.ru>, <NetSveta@upb.ru>, <root@copy-news.ru>';
#my($recip) = '<root@copy-news.ru>';


#-----------------
if (GetHtml())
{
  open(HTML,"</root/Anek/anek.html") || die "can't open /root/Anek/anek.html\n";
  open(RES,">/root/Anek/a.txt");
  print RES "To: $recip\n";
  print RES "Subject: :-)\n";
  print RES "From: anekdot\@upb.ru\n";
  print RES "MIME-Version: 1.0\n";
  print RES "Content-Transfer-Encoding: 8bit\n";
  print RES 'Content-Type: text/plain; charset="Windows-1251"' . "\n\n";
  while(<HTML>)
  {
    if (/<pre>(.*)/)  
    {
      $pr = 1; 
      $_ = $1;
    }
#  <div class="topictext">¬опреки советам военных никогда не закрывайте глаза и не падайте ногами<br />
#  в сторону €дерного взрыва, ибо в любом случае вы видите это шоу первый и<br />последний раз.</div><br />
    if (/<div class=.topictext.>(.*?)<\/div>/)
    {
      $_ = $1 . "\n\n\n"; 
      s/<br.\/>/\n/gi;
      print RES "$_";
    }
#<div class="text">Ќовое открытие сделали американские ученые: оказываетс€, iPhone 4<br />снижает содержание хлора в американской кур€тине до санитарных<br />стандартов –оссии..</div>    
    if (/<div class=.text.*?>(.*?)<\/div>/)
    {
      $_ = $1 . "\n\n\n"; 
      s/<br.\/>/\n/gi;
      print RES "$_";
    }

    if ($pr == 1)   
    {
      s/<INDEX>//;
      s/<\/INDEX>//;
      if (/(.*)<\/pre>/)
      {
        $pr = 0;
        $_ = $1 . "\n\n\n"; 
      }
      print RES "$_";
    }
  }

  close(RES);
  close(HTML);
}
#system('c:\usr\lib\sendmail -t </root/Anek/a.txt');

# онвертируем из UTF-8 в WIN1251
system('iconv -f UTF-8 -t Windows-1251 /root/Anek/a.txt > /root/Anek/b.txt');
system('/usr/sbin/sendmail -t </root/Anek/b.txt');

#system('sendmail </root/Anek/a.txt');


sub ParseOneStr {

}


#--------------------
sub GetHtml
{
  $lwp = LWP::UserAgent->new;
#  $lwp->proxy(['http','ftp'],'http://proxy:8080/');
#  $lwp->credentials('','','up_bank\sys','bynthytnnhfabr');
  $r = HTTP::Request->new(GET => "$url");
#  $r->proxy_authorization_basic('sys','bynthytnnhfabr');
  $response = $lwp->request($r);
  if ($response->is_success)
  {
    @html = $response->content;
  }
  else
  {
    @html = $response->error_as_HTML;
  }

  open(HTML,">/root/Anek/anek.html") || die "can't open /root/Anek/anek.html\n";

  foreach (@html) {
    s/<div/\n<div/gi;
    print HTML $_;
  }

  #print HTML @html;
  close(HTML);
  return $response->is_success;
}


