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
        while ( $_ =~ m{$reg1}mg) {
            push @str, $1;
            push @pers, $2 if $2;
            if ($reg2) {
                while ( $str[0] =~ m{$reg2}mg) {
                    push @text, $1;
                    push @rus, $2 if $2;
                }
            }
        }
    }    
    return $reg2 ? (\@text, \@rus): (\@str, \@pers);
}

sub find {
    my ($self, $base, $mail, $imdb) = @_;
    my (@d, %glob, $pics, $text, $rus, $form);
    $glob{'0_1_0'} = $mail;
    $glob{'0_2_0'} = $imdb;
    my $snip  = LoadFile($base.0);
    my $size = $#{$snip->[2]};
    push @d, $snip->[2][$_]    for 0..$size;

    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    my $resmail = LWP::UserAgent->new->get($d[0][5][1].$mail, 'User-Agent' => $UA); 
    my $resimdb = LWP::UserAgent->new->get($d[0][4][0].$imdb, 'User-Agent' => $UA);        
    my $respers = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][7], 'User-Agent' => $UA);
    my $resfoto = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][1], 'User-Agent' => $UA);
    my ($adr, $pers) = _mine($respers, $d[0][4][8]);
    my ($fst, $kadr) = _mine($resfoto, $d[0][4][3]);
    for my $x (1..$size) {
        my ($a, $b);
        if ( ($d[$x][2] =~ /^(\d+)_(\d+)$/)) {
            ($a, $b) = ($1, $2);
        }
        if ($d[$x][3] == 1) {
            ($text) = _mine($resimdb, $d[$x][4]);
            $glob{$x.'_0_0'} = $text->[0];
        }
        elsif ($d[$x][3] == 2) {
            for my $y (0..$a) {
                ($text) = _mine( $resmail, $d[$x][4], $d[$x][5]);
                $glob{$x.'_'.$y.'_0'} = $text->[$y] if $text->[$y];
            }
        }
        elsif ($d[$x][3] == 3) {
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
        elsif ($d[$x][3] == 4) {
            ($text) = _mine( $resmail, $d[$x][4], $d[$x][5]);
            $glob{$x.'_0_0'} = $text->[0];
            ($text) = _mine($resimdb, $d[0][5][7]);
            $glob{$x.'_1_0'} = $text->[0]; 
        }
    }
    my $path = $snip->[4][0].$snip->[4][4];
    my $temp = $snip->[4][0].$snip->[4][7];
    unlink glob "$path*.*";
    unlink glob "$temp*.*";
    ($text) = _mine($resimdb, $d[0][4][9]);
    getstore($text->[0], $path.'0.jpg');
    my $x = 0;
    for (@$kadr) {
        my $reskadr = LWP::UserAgent->new->get($d[0][4][0].
                                        $imdb.$d[0][4][4].$_, 'User-Agent' => $UA);
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
        $image->Write($temp.$_.'.jpg');
    }
    return \%glob
}

sub base {
    my ($self, $dba, $find, $base) = @_;
    my (@d);
    my $snip  = LoadFile($base.0);
    my $size = $#{$snip->[2]};
    push @d, $snip->[2][$_]    for 0..$size;    
    my (@find, @mail, @imdb);
	for my $x (1..$#{$dba}) {
	    if (uc $dba->[$x][1][0] =~ m{.*?$find.*?}img or 
            uc $dba->[$x][1][1] =~ m{.*?$find.*?}img) {
            push @find, $x;
	    }
	}
    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    my $resmail = LWP::UserAgent->new->get($d[0][5][0].$find, 'User-Agent' => $UA);
    my $path = $snip->[4][0].$snip->[4][4];
    unlink glob "$path*.*";
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
    $x = 0;
    for (@$text) {
        $resimdb = LWP::UserAgent->new->get($d[0][4][0].$_, 'User-Agent' => $UA);
        ($text) = _mine($resimdb, $d[0][4][9]);
        $titl->[$x] =~ tr[</a>][ ]d;
        getstore($text->[0], $path.$_.'.jpg');
        push @imdb, [$_, $titl->[$x]];
        ++$x;
    }
    return \@find, \@mail, \@imdb, $kadr
}
sub roles {
    my ($self, $base, $bnumb, $numb, $imdb) = @_;
    my (@d, $text, %actors);
    my $snip  = LoadFile($base.0);
    my $size = $#{$snip->[2]};
    push @d, $snip->[2][$_] for 0..$size;
    my $dba  = LoadFile($base.$bnumb);

    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    my $resimdb = LWP::UserAgent->new->get($d[0][4][0].$imdb.$d[0][4][7], 'User-Agent' => $UA);
    ($text) = _mine($resimdb, $d[0][4][13]);    
    my ($adr, $pers) = _mine($resimdb, $d[0][4][8]);
    my $first = $dba->[$numb][8][0][2];
    my @roles;
    for (@$text) {
        if ($_ =~ m{<a.*?>(.*?)</a>}mg) {
            push @roles, $1
        }
        else {
            push @roles, $_
        }
    }
    my @pers = @$pers;
    my (@actors, $flag);
    for (@pers) {
        if ($_ eq $first && $flag != 1) {
           push @actors, $_;
           $flag = 1;
        }
        elsif ($flag == 1) {
            push @actors, $_;
        }
    }
    for my $x (0..13) {
        for my $y (0..$#roles) {
            if (length($dba->[$numb][8][$x][0]) > 0) {
                if ($dba->[$numb][8][$x][2] eq $actors[$y]) {
                   $dba->[$numb][8][$x][3] = $roles[$y];
                }
            }
        }        
    }
    DumpFile($base.$bnumb, $dba);

    my $dba2 = LoadFile('/home/marat/Base/b/9');
    my $next = $#{$dba2} + 1;
    my $z = $numb;
    for my $x (0..6) {
        for my $y (0..6) {
            if (exists $dba->[$z][$x][$y]) {
                $dba2->[$next][$x][$y] = $dba->[$z][$x][$y]
            }
        }
    }
    for my $x (7..12) {
        $dba2->[$next][$x][0] = [];
        for my $y (0..14) {
            if (exists $dba->[$z][$x][$y][0]) {
                $dba2->[$next][$x][$y][0] = $dba->[$z][$x][$y][0];
                $dba2->[$next][$x][$y][1] = $dba->[$z][$x][$y][1];
                $dba2->[$next][$x][$y][2] = $dba->[$z][$x][$y][2];
                if ($dba->[$z][$x][$y][3] ne 'blank' 
                    and $dba->[$z][$x][$y][3] ne $dba->[$z][$x][$y][0]
                    and exists $dba->[$z][$x][$y][3] ) {
                    $dba2->[$next][$x][$y][3] = $dba->[$z][$x][$y][3];
                }
            }
        }
    }
    $dba2->[$next][13][0] = $dba->[$z][13][0];
    $dba2->[$next][13][1] = $dba->[$z][13][1];
    my @film = @$dba2;
    @film = sort {                                                      # SORT BY YEAR AND REIT
        $a->[3][0] cmp $b->[3][0]
        ||
        $b->[2][0] cmp $a->[2][0]
    } @film;
    $dba2 = [@film];
    DumpFile('/home/marat/Base/b/9', $dba2);
}
=encoding utf8
=head1 AUTHOR
Marat Haakimoff
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut
__PACKAGE__->meta->make_immutable;
1;
