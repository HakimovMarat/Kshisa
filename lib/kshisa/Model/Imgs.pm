package kshisa::Model::Imgs;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use File::Copy;
use LWP;
use LWP::Simple qw(getstore);

extends 'Catalyst::Model';

=head1 NAME
kshisa::Model::Imgs - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=cut

sub pics {
	my ($self, $base, $numb, $mini, $basenumb, $text) = @_;
    my $dba  = LoadFile($base.$basenumb);
	my $code = $dba->[$numb][0][0];
	my $foto = $mini.$code.'m';
    my $w = 1020;
    my $h = 600;
    my $y = 100;
    my $x = 10;
    my $k;
	my $p = '<img id="post" name="post"  src="'.$foto.'0.jpg"/>'; 
    if ($text  =~ /(\d+)/) {
        $k = '<img style="height: 363px;" src="/images/kads/'.$code.'k'.$1.'.jpg">'
    }
    else {
        $k = '<span><img class="kadr" name="kadr0" src="'.$foto.'1.jpg"/>
             1<input  type="checkbox" name="m1"></span>
             <span><img class="kadr" name="kadr1" src="'.$foto.'2.jpg"/>
         	 2<input  type="checkbox" name="m2"></span>
             <span><img class="kadr" name="kadr2" src="'.$foto.'3.jpg"/>
         	 3<input  type="checkbox" name="m3"></span>
             <span><img class="kadr" name="kadr3" src="'.$foto.'4.jpg"/>
         	 4<input  type="checkbox" name="m4"></span>';
    }           
   
    my $full = '<div id="imgs">'.$p.'<div id="foto">'.$k.'<hr>
                w <input type="text"  name="w" value="'.$w.'" size="2" />
                h <input type="text"  name="h" value="'.$h.'" size="2" />
                y <input type="text"  name="y" value="'.$y.'" size="2" />
                x <input type="text"  name="x" value="'.$x.'" size="2" />
                </div>'
			  .'<h3>'.$dba->[$numb][1][0].'</h3>
			    <h3>'.$dba->[$numb][1][1].'</h3>
			    <h3>'.$dba->[$numb][3][0].'</h3>
                <h3>Imdb: '.($dba->[$numb][2][0]/10).'</h3>
                <input type="image" name="prevr" src="/images/bill/lt.png">
                <input type="image" name="nextr" src="/images/bill/rt.png">
                <hr><h3>'.$numb.'/'.$#{$dba}.'</h3>
                <input type="image" name="find0" src="/images/butt/dn3.png">
                '.$text.'
                </div>';
    return $full
}
sub rows {
    my ($self, $base, $numb, $kads, $basenumb, $newpost) = @_;
    my $dba0  = LoadFile($base. $basenumb);
    my $code = $dba0->[$numb][0][0];
    my $max = $dba0->[$numb][0][3];
    my $foto = $kads.$code.'k';
    my $rows;
    $rows = '<div id="rows"><hr>'.$rows.$max;
    $rows = $rows.'<div style="float: left"><img class="image" name="" src="'.$newpost.$code.'p2.jpg">
                   <button name="'.$code.'">P2</button></div><div>';
    for (1..$max) {
        $rows = $rows.'<input type="image" class="image" name="kk'.$_.'" src="'.$foto.$_.'.jpg"/><button name="kad'.$_.'">'.$_.'</button>';
    }
    $rows = $rows.'</div></div><hr>';
    return $rows
}
sub newfoto {
    my ($self, $code, $crewf, $imgs4, $base, $basenumb) = @_;
    my $dba  = LoadFile($base.1);
    my $dba0  = LoadFile($base.$basenumb);
    my ($addr, $numb);
=c
    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    my $imdb = LWP::UserAgent->new->get('https://www.imdb.com/name/'.$addr, 'User-Agent' => $UA);
    for ($imdb->decoded_content) {
		while ( $_ =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
			getstore($1, $crewf.$code.'.jpg');
            
		}
	}   
=cut
    rename ($crewf.'0.jpg', $crewf.$code.'.jpg');
    copy ($crewf.$code.'.jpg', $imgs4.$code.'.jpg');
    for (1..$#{$dba}) {
        if ($dba->[$_][0] eq $code) {
            $addr = $dba->[$_][3];
            $dba->[$_][4 ] = 1;
        }
    }
    for my $x (1..$#{$dba0}) {
        for my $y (7..12) {
            for my $z (0..$dba0->[0][$y][2]) {
                if ($dba0->[$x][$y][$z] and $dba0->[$x][$y][$z][0] eq $code) {
                    $dba0->[$x][$y][$z][3] = $dba0->[$x][$y][$z][0];
                    ++$numb
                }                
            }
        }
    }
    DumpFile($base.1, $dba);
    DumpFile($base.$basenumb, $dba0);
    return $numb    
}
=encoding utf8
=head1 AUTHOR
Marat,,,
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut

__PACKAGE__->meta->make_immutable;

1;
