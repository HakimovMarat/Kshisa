package kshisa::Controller::Root;
use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => '');

=encoding utf-8
=head1 NAME
kshisa::Controller::Root - Root Controller for kshisa
=head1 DESCRIPTION
SPA Controller
=head1 METHODS
=head2 index
The root page (/)
=cut

sub index :Path :Args(0) {
  my ($self, $c) = @_;
  my ($find, $logs, $text, $root, $glob, $mail, $imdb, 
      $addr1, $addr2, $head, $left, $form, $pics, $rigt, $srch, $news, $site);
  my $param = $c->req->body_params;    
  my $base  = $c->config->{'base'};
  my $imgs  = $c->config->{'imgs'};
  my $home  = $c->config->{'home'};
  
  my $dbab = LoadFile($base.'news');
  my $code = $dbab->[$#{$dbab}][0][0];
  if ($code =~ /(\d+)f\d+/) {
    $news = $1
  }
  my $last = $dbab->[$#{$dbab}][0][4];

  my $bnumb = $param->{files} || $news;
  my $pnumb = $param->{tapes} || 1;
  my $numb  = $param->{numb1} || $last;
  my $numb2 = $param->{numb2} || 1;

  my $dba = LoadFile($base.$bnumb);
  my $pba = LoadFile($base.'c/'.$pnumb);
  my $total1 = $#{$dba};
  my $total2 = $#{$pba};   
  $numb  = 1 if $numb  > $total1;
  $numb2 = 1 if $numb2 > $total2;
  my $title = $param->{tit};
  my $kadr  = $bnumb;          # PATH TO MINIIMAGES    

  if ( $c->user_exists() ) {
    if ($param->{'sch.x'} ) {  # SEARCH
      if ($param->{Address} =~ /^(\d+_.*?)(tt\d+)/){
        $glob = $c->model('Find')->find
        ($base, $1, $2, $home);
        $title = $glob->{'1_1_0'};
      }
      elsif ($param->{Address} =~ /^(\d+)$/){
        if ($1 <= $total1){$numb = $1}
        else {$numb = $total1};
        $glob = $c->model('Data')->readds
        ($numb, $bnumb, $base);
      }
      else {
        $title = $param->{Address};
        ($find, $mail, $imdb) = $c->model('Find')->base
        ($dba, $title, $base, $home, $param, $bnumb);
        if ($find->[0]) {
          if ($find->[0][0] =~ /(\d+)f((\d+)f\d+)/) {
            $numb = $1;
            $bnumb = $3;
            $kadr  = $bnumb
          }
        }
        $glob = $c->model('Data')->readds($numb, $bnumb, $base);
      }
    }
    elsif ($param->{'find.x'}) {
      foreach my $key (keys %$param) {
        if ($key =~ /ff(\d+_.*?)ff/) {
          $addr1 = $1
        }
        elsif ($key =~ /(tt\d+)/) {
          $addr2 = $1
        }
      }
      ($glob) = $c->model('Find')->find
      ($base, $addr1, $addr2, $home);
    }
    else {
      if ($param->{'rt1.x'}){
        if ($numb == $total1) { $numb = 1 }
        else { $numb = $numb + 1 }
      }
      elsif ($param->{'lt1.x'}){
        if ($numb == 1) { $numb = $total1 }
	      else { $numb = $numb - 1 }
	    }
      elsif ($param->{'rt2.x'}){
        if ($numb2 == $total2) { $numb2 = 1 }
        else { $numb2 = $numb2 + 1 }
      }
      elsif ($param->{'lt2.x'}){
        if ($numb2 == 1) { $numb2 = $total2 }
	      else { $numb2 = $numb2 - 1 }
	    }
      elsif ($param->{'insert.x'}){
       ($numb, $bnumb) = $c->model('Data')->insert($base, $param, $bnumb, $home);
        ++$total1;
        $kadr = $bnumb;
      }
      elsif ($param->{'del1.x'}){
        my $f = 0;
        foreach my $key (keys %$param) {
          if ($key =~ /kad\d+/) {
            $text = 'Are you sure delete this pictures?  <button name="delpics">delpics</button>';
            $f = 1;
            last
          }
        }
        if ( $f == 0 ) {
          $text = 'Are you sure?  <button name="delete">delete</button>'
        }
      }
      elsif ($param->{'del2.x'}){
        $c->model('Data')->deltape($base, $pnumb, $numb2)
      }
      elsif ($param->{'send1.x'}){
        ($bnumb, $numb) = $c->model('Data')->send
        ($base, $bnumb, $numb, $home, $param->{Address});
        $kadr = $bnumb
      }
      elsif ($param->{'send2.x'}){
        ($bnumb, $numb, $numb2) = $c->model('Data')->tape
        ($base, $bnumb, $numb, $home, $pnumb);
        $kadr = $bnumb
      }
      elsif ($param->{'send3.x'}){
        $c->model('Find')->pers($base, $numb, $pnumb);
      }
      elsif ($param->{'del3.x'}){
        $c->model('Data')->delpers($base, $numb)
      }
      elsif ($param->{'post.x'}){
        $dba = $c->model('View')->post($base, $bnumb, $numb, $home)
        #$kadr = $dba->[$numb][0][0]
      }
      foreach my $key (keys %$param){
        if ($key =~ /^bb(\d+)_(\d+)_(\d+)_(\d)$/) {
          ($dba, $site) = $c->model('Data')->update($base, $bnumb, $numb, 
                          $1, $2, $3, $4, $param->{$1.'_'.$2.'_'.$3}, $home);
                        
          $c->response->redirect("https://kino.mail.ru/person/$site") if $site;
        }
        elsif ($key eq 'images') {
          $text = $c->model('Data')->imgs
          ($base, $bnumb, $numb, $home, $param->{'imgs'})
        }
        elsif ($key eq 'change') {
          $c->model('View')->change($numb, $base, $bnumb, $home)
        }
        elsif ($key eq 'delete') {
          $dba = $c->model('Data')->delete($base, $bnumb, $numb, $home)
        }
        elsif ($key eq 'delpics') {
          $dba = $c->model('Data')->delpics($base, $bnumb, $numb, $param)
        }
        elsif ($key =~ /(kk\d+)/) {$kadr = $1}
        elsif ($key =~ /(\d+)f(\d+)f\d+/) {
          $numb = $1;
          $bnumb = $2;
          $kadr = $bnumb;
        }
        elsif ($key =~ /mm(\d)/) {
          $kadr = $c->model('View')->mini
          ($numb, $param, $base, $bnumb, $1, 
           $param->{w}.'x'.$param->{h}.'+'.$param->{x}.'+'.$param->{y}, $home);            
        }
        elsif ($key =~ /((\d+)f\d+)/) {
          $kadr = $2;
          $bnumb = $2;
          $dba = LoadFile($base.$bnumb);
          for (1..$#{$dba}) {
            if ($dba->[$_][0][0] eq $1) {$numb = $_ }
            }
        }
	  }
    # $logs = $c->user->get('name');
    $glob = $c->model('Data')->readds($numb, $bnumb, $base);
  }    
  ($head, $left, $form, $pics, $rigt, $srch) = $c->model('View')->view
  ($numb, $bnumb, $glob, $kadr, $find, $mail, $imdb, $title, $param, $base, $home, $numb2, $pnumb);
  }   
  elsif ($param->{'P6'}) {                                             # PASSWORD VERIFICATION
    my $pass;
    for (1..6) { $pass = $pass.$param->{'P'.$_} if $param->{'P'.$_}}
      if ($c->authenticate({username => "kshisa",                        # LOG IN
                            password => $pass })) {
        $c->response->redirect($c->uri_for("/"))
      } 
      else {
        $c->res->body( "wrong password " )
      }
  }
  else {
    $pics = $c->model('Data')->logs; 
  }
  $c->stash (
    text => $text,
    head => $head,
    left => $left,
    form => $form,
    pics => $pics,
    rigt => $rigt,
    srch => $srch
  );
}

=head2 default
Standard 404 error page
=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end
Attempt to render a view, if needed.
=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR
Hakimov Marat
=head1 LICENSE
21.07.2017
This library is not free software.
=cut

__PACKAGE__->meta->make_immutable;

1;
