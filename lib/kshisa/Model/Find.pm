package kshisa::Model::Find;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use LWP;
use LWP::Simple qw(getstore);
use Image::Magick;

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
                if ($d[$x][3] == 3 and $rus->[$y]) {
                    my $resp = LWP::UserAgent->new->get($d[0][5][3].$text->[$y], 'User-Agent' => $UA);
                    my ($eng)  = _mine($resp, $d[0][5][4]);
                    $glob{$x.'_'.$y.'_2'} = $eng->[0] if $eng->[0];
                    my $z = 0;
                    for (@$pers) {
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
            ($text, $rus) = _mine( $resmail, $d[$x][4], $d[$x][5]);
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
                                        $imdb.$d[0][4][4].$_.$d[0][4][5], 'User-Agent' => $UA);
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
        push @mail, $kadr->[$x];
        ++$x;
    }
    my $resimdb = LWP::UserAgent->new->get($d[0][4][10].$find, 'User-Agent' => $UA);
    my ($text) = _mine($resimdb, $d[0][4][11]);
    for (@$text) {
        $resimdb = LWP::UserAgent->new->get($d[0][4][0].$_, 'User-Agent' => $UA);
        ($text) = _mine($resimdb, $d[0][4][9]);
        getstore($text->[0], $path.$_.'.jpg');
        push @imdb, $_;
    }
    return \@find, \@mail, \@imdb
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
