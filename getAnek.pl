#!/usr/bin/perl -w
#
#  windows 1251 use for regexp !!!
#
# 2009-12-21 ����� �������� ������ html
# 2010-06-30 ����� �������. �� ����� <pre>
# 2013-01-10 ����� �������� ������. � 1 ������ ��� ��������. :-(
# 2015-10-01 <br>

use LWP::UserAgent;
use HTTP::Request;
#---
my($url) = 'http://www.anekdot.ru/last/j.html';
my(@html);
my($pr) = 0;
my($recip) = '<nvimc@mail.ru>, <NetSveta@upb.ru>, <hrushev.av@kubank.ru>, <root@copy-news.ru>';


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
#  <div class="topictext">������� ������� ������� ������� �� ���������� ����� � �� ������� ������<br />
#  � ������� �������� ������, ��� � ����� ������ �� ������ ��� ��� ������ �<br />��������� ���.</div><br />
    if (/<div class=.topictext.>(.*?)<\/div>/i)
    {
      $_ = $1 . "\n\n\n"; 
      s/<br.*?>/\n/gi;
      print RES "$_";
    }
#<div class="text">����� �������� ������� ������������ ������: �����������, iPhone 4<br />������� ���������� ����� � ������������ �������� �� ����������<br />���������� ������..</div>    
    if (/<div class=.text.*?>(.*?)<\/div>/i)
    {
      $_ = $1 . "\n\n\n"; 
      s/<br.*?>/\n/gi;
      print RES "$_";
    }

  }

  close(RES);
  close(HTML);
}
#system('c:\usr\lib\sendmail -t </root/Anek/a.txt');

#������������ �� UTF-8 � WIN1251
system('iconv -f UTF-8 -t Windows-1251 /root/Anek/a.txt > /root/Anek/b.txt');
system('/usr/sbin/sendmail -t </root/Anek/b.txt');

#system('sendmail </root/Anek/a.txt');




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
