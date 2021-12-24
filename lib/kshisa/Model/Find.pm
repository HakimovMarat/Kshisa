package kshisa::Model::Find;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use LWP;
use LWP::Simple qw(getstore);
use Image::Magick;
use utf8;

extends 'Catalyst::Model';
=head1 NAME
kshisa::Model::Find - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=cut

sub _mine {
  my ($resp, $reg1, $reg2) = @_;
  my (@text, @rus, @str, @pers);
  for ($resp->decoded_content) {
    while ( $_ =~ m{$reg1}mgs) {
      push @str, $1;
      push @pers, $2 if $2;
      if ($reg2) {
        while ( $str[0] =~ m{$reg2}mgs) {
          push @text, $1;
          push @rus, $2 if $2;
        }
      }
    }
  }    
  return $reg2 ? (\@text, \@rus): (\@str, \@pers);
}

sub find {
  my ($self, $base, $mail, $imdb, $home, $title) = @_;
  my (@d, @f, %glob, $pics, $text, $rus, $form);
  $glob{'0_1_0'} = $mail;
  $glob{'0_2_0'} = $imdb;
  my $snip  = LoadFile($base.0);
  push @d, $snip->[2][$_]  for 0..$#{$snip->[2]};
  push @f, $snip->[4][$_]  for 0..$#{$snip->[5]};

  my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
  my $resmail = LWP::UserAgent->new->get($d[0][5][1].$mail, 'User-Agent' => $UA); 
  my $resimdb = LWP::UserAgent->new->get($d[0][4][0].$imdb.'/', 'User-Agent' => $UA);        
  my $respers = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][7], 'User-Agent' => $UA);
  my $resfoto = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][1], 'User-Agent' => $UA);
  my ($adr, $pers) = _mine($respers, $d[0][4][8]);
  my ($fst, $kadr) = _mine($resfoto, $d[0][4][3]);
  for my $x (1..$#{$snip->[2]}) {
    my ($a, $b);
    if ( ($d[$x][2] =~ /^(\d+)_(\d+)$/)) {
      ($a, $b) = ($1, $2);
    }
    if  ($d[$x][1] == 1) {
      ($text) = _mine( $resimdb, $d[$x][4]);
      $glob{$x.'_0_0'} = $text->[0];
    }
    elsif ($d[$x][1] == 2) {
      for my $y (0..$a) {
        ($text) = _mine( $resmail, $d[$x][4], $d[$x][5]);
        $glob{$x.'_'.$y.'_0'} = $text->[$y] if $text->[$y];
      }
    }
    elsif ($d[$x][1] == 3) {
      for my $y (0..$a) {
        ($text, $rus) = _mine( $resmail, $d[$x][4], $d[$x][5]);
        $glob{$x.'_'.$y.'_0'} = $text->[$y] if $text->[$y];
        $glob{$x.'_'.$y.'_1'} = $rus->[$y]  if $rus->[$y];
        if ($rus->[$y]) {
          my $resp = LWP::UserAgent->new->get($d[0][5][3].$text->[$y], 'User-Agent' => $UA);
          my ($eng)  = _mine($resp, $d[0][5][4]);
          $glob{$x.'_'.$y.'_2'} = $eng->[0] if $eng->[0];
          my $z = 0;
          for (@$pers) {
            $_ =~ tr[é][]d;
            $eng->[0] =~ tr[&#233;][]d;
            $_ =~ tr[è][]d;
            $eng->[0] =~ tr[&#232;][]d;
            $_ =~ tr[ç][]d;
            $eng->[0] =~ tr[&#231;][]d;
            $_ =~ tr[í][]d;
            $eng->[0] =~ tr[&#237;][]d;
            $_ =~ tr[ì][]d;
            $eng->[0] =~ tr[&#236;][]d;
            $_ =~ tr[ñ][]d;
            $eng->[0] =~ tr[&#241;][]d;
            if ($eng->[0] eq $_) {
              $glob{$x.'_'.$y.'_3'} = $adr->[$z];
              last
            }
            else {
              $glob{$x.'_'.$y.'_3'} = '';
            }
              $z++;
          }
        }                              
      }                
    }
    elsif ($d[$x][1] == 4) {
      ($text) = _mine( $resmail, $d[$x][4], $d[$x][5]);
      $glob{$x.'_0_0'} = $text->[0];
      ($text) = _mine( $resimdb, $d[$x][8]);
      $glob{$x.'_1_0'} = $text->[0]; 
    }
  }
  my $path = $home.$f[4];

  ($text) = _mine($resimdb, $d[0][4][9]);
  getstore($text->[0], $path.'0.jpg');
  my $x = 0;
  for (@$kadr) {
    my $reskadr = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][4].$_, 'User-Agent' => $UA);
    ($text) = _mine($reskadr, $d[0][4][6]);
    if ($text->[0]) {
      getstore($text->[0], $path.($x += 1).'.jpg');
    }
  }
  $glob{'0_3_0'} = $x;
  for (1..$x) {
    my $image = Image::Magick->new;
    $image->Read($path.$_.'.jpg');
    $image->Set(Gravity => 'Center');
    $image->Resize(geometry => '350x240');
    $image->Write($path.$_.'.jpg');
  }
  return \%glob
}

sub base {
  my ($self, $dba, $find, $base, $home, $param, $bnumb) = @_;
  my (@d, @f, @find, @mail, @imdb);
  my $snip  = LoadFile($base.0);
  push @d, $snip->[2][$_] for 0..$#{$snip->[2]};
  push @f, $snip->[4][$_] for 0..$#{$snip->[4]};
  my $path = $home.$f[4].'0/';
  #unlink glob "$path*.*";
  if ($bnumb == 1) {
    my $file = LoadFile($base.1);
    for my $x (1..$#{$file}) {
      if (uc $file->[$x][1][0] =~ m{.*?$find.*?}img or uc $file->[$x][1][1] =~ m{.*?$find.*?}img) {
        push @find,[ $x.'f'.$file->[$x][0][0], $file->[$x][1][0]]
      }
    }
  }
  else {
    if ($param->{base}) {
      my @files = (5..$#{$snip->[1]});
	    for my $n (@files) {
        my $file = LoadFile($base.$n);
	      for my $x (1..$#{$file}) {
	        if (uc $file->[$x][1][0] =~ m{.*?$find.*?}img or uc $file->[$x][1][1] =~ m{.*?$find.*?}img) {
            push @find,[ $x.'f'.$file->[$x][0][0], $file->[$x][1][0], $file->[$x][3][0]]
	        }
        }
	    }
    }
    if ($param->{mail}) {
      my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
      my $resmail = LWP::UserAgent->new->get($d[0][5][0].$find, 'User-Agent' => $UA);
      my ($fst, $kadr) = _mine($resmail, $d[0][5][2]);
      my $x = 0;
      for (@$fst) {
        if ($_ =~ /.*?nopicture.*?/) {
          getstore($d[0][5][8].$_, $path.$kadr->[$x].'.jpg');
        }
        else {
          getstore($_, $path.$kadr->[$x].'.jpg');
        }
        my ($title, $year) = _mine($resmail, $d[0][5][9]);
        push @mail, [$kadr->[$x], $title->[$x].$year->[$x]];
        ++$x;
      }
      my $resimdb = LWP::UserAgent->new->get($d[0][4][10].$find, 'User-Agent' => $UA);
      my ($text, $titl) = _mine($resimdb, $d[0][4][11]);
      #my $filename = $home.$f[4].'imdb.html';
      #open my $fh, '>', $filename;
      $x = 0;
      for my $imdb (@$text) {
        my $resfind = LWP::UserAgent->new->get($d[0][4][0].$imdb.'/', 'User-Agent' => $UA);
        my($text) = _mine($resfind, $d[0][4][9]);
        #my $content = $resfind->decoded_content;
        #print $fh $content;
        $titl->[$x] =~ tr[</a>][ ]d;
        getstore($text->[0], $path.$imdb.'.jpg');
        push @imdb, [$imdb, $titl->[$x]];
        ++$x;
      }
    }
  }
  return \@find, \@mail, \@imdb
}
sub pers {
  my ($self, $base, $numb, $bnumb) = @_;
  my (@d);
  my $snip = LoadFile($base.0);
  push @d, $snip->[2][$_]  for 0..$#{$snip->[2]};
  my $dba1 = LoadFile($base.1);
  my $dba2 = LoadFile($base.'b/'.1);
  my $size = $#{$dba2} + 1;
  # my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
  for my $pers ($numb..$numb + 99) {
    my (@films, @best, $born, $died);
    # my $resimdb = LWP::UserAgent->new->get('https://www.imdb.com/name/'.$dba1->[$pers][0][2], 'User-Agent' => $UA);
    # ($born, $died) = _mine($resimdb, $d[0][4][5]);
    for my $n (5..$#{$snip->[1]}) {
      my $file = LoadFile($base.$n);
      for my $x (1..$#{$file}) {
        my $prof;
        for my $y (7..12) {
          for my $z (0..$file->[0][$y][2]) {
            if ($file->[$x][$y][$z][0] eq $dba1->[$pers][0][0]) {
              $prof .= $snip->[2][$y][0].':';
            }
          }
        }
        if (length($prof) > 0) {
          push @films, [$file->[$x][0][0], $file->[$x][1][0], , $file->[$x][2][0], $prof]
        }
      }
    }
    @films = sort {$b->[2] cmp $a->[2]} @films;

    #if ($born->[0]*1 == 0) {
    #     ($born) = _mine($resimdb, $d[0][4][2]);
    #    $dba1->[$pers][3][0] = $born->[0]*1;
    #    $dba2->[$size][3][0] = $born->[0]*1;
    #}
    #else {    
    #    $dba2->[$size][3][0] = $born->[0]*1;
    #    $dba2->[$size][3][1] = $died->[0]*1;
    #    $dba1->[$pers][3][0] = $born->[0]*1;
    #    $dba1->[$pers][3][1] = $died->[0]*1; 
    #}
    $dba2->[$size][0][0] = $dba1->[$pers][0][0];
    $dba2->[$size][0][1] = $dba1->[$pers][0][1];
    $dba2->[$size][0][2] = $dba1->[$pers][0][2];
    $dba2->[$size][1][0] = $dba1->[$pers][1][0];
    $dba2->[$size][1][1] = $dba1->[$pers][1][1];
    $dba2->[$size][2][0] = $dba1->[$pers][2][0];
    $dba2->[$size][3][0] = $dba1->[$pers][3][0];
    $dba2->[$size][3][1] = $dba1->[$pers][3][1];
 
    for (0..$#films) {
      $dba2->[$size][4][$_][0] = $films[$_][0];
      $dba2->[$size][4][$_][1] = $films[$_][1];
      $dba2->[$size][4][$_][3] = $films[$_][2];
      $dba2->[$size][4][$_][2] = $films[$_][3]; 
   }
    ++$size;
  }
  DumpFile($base.'b/'.1, $dba2);
}

=encoding utf8
=head1 AUTHOR
Marat Hakimov
=head1 LICENSE
This library is not free software. You cannot redistribute it and/or modify
it under the same terms as Perl itself.
=cut
__PACKAGE__->meta->make_immutable;
1;
