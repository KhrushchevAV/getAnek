#!/usr/bin/perl -w
#
#  windows 1251 use for regexp !!!
#
# 2009-12-21 ����� �������� ������ html
# 2010-06-30 ����� �������. �� ����� <pre>
# 2013-01-10 ����� �������� ������. � 1 ������ ��� ��������. :-(

use LWP::UserAgent;
use HTTP::Request;
#---
my($url) = 'http://www.anekdot.ru/last/j.html';
my(@html);
my($pr) = 0;
my($recip) = '<nvimc@mail.ru>, <sed@upb.ru>, <urasov@upb.ru>, <vedenina@upb.ru>, <ermakov@ipae.uran.ru>, <NetSveta@upb.ru>, <gaz@upb.ru>, <grishins@inbox.ru>, <slava@upb.ru>, <av@upb.ru>';
#my($recip) = '<av@upb.ru>';


#-----------------
if (GetHtml())
{
  open(HTML,"<anek.html") || die "can't open anek.html\n";
  open(RES,">a.txt");
  print RES "To: $recip\n";
  print RES "Subject: :-)\n";
  print RES "From: av\@upb.ru\n";
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
#  <div class="topictext">������� ������� ������� ������� �� ���������� ����� � �� ������� ������<br />
#  � ������� �������� ������, ��� � ����� ������ �� ������ ��� ��� ������ �<br />��������� ���.</div><br />
    if (/<div class=.topictext.>(.*?)<\/div>/)
    {
      $_ = $1 . "\n\n\n"; 
      s/<br.\/>/\n/gi;
      print RES "$_";
    }
#<div class="text">����� �������� ������� ������������ ������: �����������, iPhone 4<br />������� ���������� ����� � ������������ �������� �� ����������<br />���������� ������..</div>    
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
#system('c:\usr\lib\sendmail -t <a.txt');
system('sendmail <a.txt');


sub ParseOneStr {

}


#--------------------
sub GetHtml
{
  $lwp = LWP::UserAgent->new;
#  $lwp->proxy(['http','ftp'],'http://proxy:8080/');
#  $lwp->credentials('','','up_bank\sys','bynthytnnhfabr');
#  $r = HTTP::Request->new(GET => "$url");
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

  open(HTML,">anek.html") || die "can't open anek.html\n";

  foreach (@html) {
    s/<div/\n<div/gi;
    print HTML $_;
  }

  #print HTML @html;
  close(HTML);
  return $response->is_success;
}


