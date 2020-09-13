package kshisa::Model::View;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use File::Copy;

extends 'Catalyst::Model';

=head1 NAME

kshisa::Model::View - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub view {
    my ($self, $numb, $bnumb, $base, $dba, $glob, $kadr, $find, $mail, $imdb) = @_;
    my (@d, @t, @s, @o, @f, @i, $crew, $rigtp, $size);
    my $snip  = LoadFile($base.0);
    if ($bnumb == 1 or $bnumb == 2 or $bnumb == 3) {
        $size = $#{$snip->[3]};
        push @d, $snip->[3][$_] for 0..$size;
    }
    else {
        $size = $#{$snip->[2]};
        push @d, $snip->[2][$_] for 0..$size;        
    }
    my %glob = %$glob;
    my $code = $glob{'0_0_0'};

    push @f, $snip->[4][$_]    for 0..6;
    push @i, $snip->[0][0][$_] for 0..15;
    push @t, $snip->[0][3][$_] for 0..14;
    push @s, $snip->[0][1][$_] for 0..7;
    push @o, $snip->[0][2][$_] for 0..11;

    my $panl = '<input type="hidden" name="idr" value="'.$numb.'" />
                <input type="hidden" name="idb" value="'.$bnumb.'" />'.
                $i[13].'Logo'.$i[14].
                $i[1].'image'.$i[3].'logo'.$i[4].'logout'.$i[5].$f[3].'kshisa'.$i[7].
                $i[15].
                '<div id="panl"><select id="addr" name="files" >';            
                for (1..$#{$snip->[1]}) {
                    if ($snip->[1][$_][0]) {
	                    $panl =  $panl.'<option value="'.$_.'"';
                        if ($_ eq $bnumb) {
                            $panl =  $panl.'selected="selected"';
                        }
                        $panl =  $panl.'>'.$snip->[1][$_][0].'</option>';            
                    }
                }
    $panl .= '</select>
              <input type="text" id="address" name="Address" size="35">';
           
    if ($glob{'0_0_0'}) {
        $panl .= $i[1].'image'.
                 $i[3].'search'.
                 $i[4].'sch'.
                 $i[5].$f[3].'sch'.$i[7].
                 $i[8].
                 $i[10];
    }        
    else {
        $panl .= $i[1].'image'.
                 $i[3].'search'.
                 $i[4].'insert'.
                 $i[5].$f[3].'chek'.$i[7].
                 $i[8].
                 $i[10];
    }        
    $panl .= $i[13].'Clock'.$i[14].
             $i[13].'Date'.$i[14].$i[15].
             $i[13].'hours'.$i[14].$i[15].
             $i[13].'min'.$i[14].$i[15].
             $i[13].'sec'.$i[14].$i[15].
             $i[15];
    $panl .= '<div id="weather">
              <a target="_blank" href="http://nochi.com/weather/kazan-4422">
              <img style="width:155px; height:50px;" 
              src="https://w.bookcdn.com/weather/picture/1_4422_1_20_babec2_320_ffffff_333333_08488D_1_ffffff_333333_0_6.png?scode=124&domid=589&anc_id=35927"  
              alt="booked.net"/></a>'.$i[15].$i[15];
    my $form = '';
    for my $x (0..$size) {
        my ($a, $b);
        if ( ($d[$x][2] =~ /^(\d+)_(\d+)$/)) {
            ($a, $b) = ($1, $2);
        }
        for my $y (0..$a) {
            if ($glob{$x.'_'.$y.'_0'}) {
                for my $z (0..$b) {
                    if ($d[$x][1] == 1) {
                        $form .= $s[0].$s[1].$s[2].$d[$x][0].' '.($y+1).
                        $s[3].$x.'_'.$y.'_'.$z.$s[4].
                        $glob{$x.'_'.$y.'_'.$z}.$s[5].$s[6];
                    }
                    elsif ($d[$x][1] == 2 && !$code) {
                        $form .= $s[0].$s[1].$s[2].$d[$x][0].' '.($y+1).
                        $s[3].$x.'_'.$y.'_'.$z.$s[4].
                        $glob{$x.'_'.$y.'_'.$z}.$s[5].$s[6]
                        if $glob{$x.'_'.$y.'_'.$z};
                    }
                    elsif ($d[$x][3] == 4) {
                        $form .= $t[0].$t[1].$t[2].$t[3].$d[$x][0].' '.($y+1).
                        $t[4].$t[8].$t[9].$t[0].$t[1].$t[5].
                        $x.'_'.$y.'_'.$z.$t[6].
                        $glob{$x.'_'.$y.'_'.$z}.$t[7].$t[8].$t[9];
                    }                                       
                }                    
            }
            for my $z (0..4) {
                if ($d[$x][1] == 2 && $z == 0 && $code) {
                    my %files = ('coun' => LoadFile($base.2),
	                             'genr' => LoadFile($base.3),
	                            );
                    my $rows = $files{$d[$x][0]}; 
		            $form .= $o[0].$o[1].$glob{$x.'_0_1'}.
                    $o[2].$d[$x][0].' '.($y+1).$o[3].$o[4].$o[5].$o[6].$o[7];
			        for my $list (1..$#{$rows}) {
				        $form .= $o[5].$rows->[$list][0][1];
                        if ($glob{$x.'_'.$y.'_1'}) {
                            $form .= $o[11] if $rows->[$list][0][1] eq $glob{$x.'_'.$y.'_1'};
                        }
				        $form .= $o[6].$rows->[$list][1][0].$o[7];
			        } 
			        $form .= $o[8].$o[9].$o[10];
                }
                
            }
            if ($d[$x][3] == 3) {
                if ($glob{$x.'_'.$y.'_0'}) {
                    $crew .= $i[0].$i[1].'image'.
                             $i[2].'image'.
                             $i[4].$glob{$x.'_'.$y.'_0'}.
                             $i[5].$f[6].$glob{$x.'_'.$y.'_3'}.
                             $i[6].$i[8].
                             ($y+1).' '.$dba->[0][$x][5].
                             $i[9].$glob{$x.'_'.$y.'_1'}.
                             $i[9].$glob{$x.'_'.$y.'_2'}.
                             $i[10].$i[11];
                }
            }
        }
    }
    $form = $t[10].$form.$t[11]; 

    my $pics = '<div id="pics">';
    my ($pic, $next, $name, $path);
    if ($code && $snip->[1][$bnumb][1] == 0) {
        my $k;
        my $p = '<img class="post" name="post"  src="/images/images/'.$code.'p2.jpg"/>';
        if ($kadr =~ /kk(\d+)/) {
            $k = '<img style="margin-right: 21px; margin-left: 8px; margin-top: 4px;" 
                  src="/images/images/'.$code.'k'.$1.'.jpg">'
        }
        else {
            $k = '<input type="image" class="kadr" name="mm1" src="'.$f[$kadr].$code.'m1.jpg"/>
                  <input type="image" class="kadr" name="mm2" src="'.$f[$kadr].$code.'m2.jpg"/>
                  <input type="image" class="kadr" name="mm3" src="'.$f[$kadr].$code.'m3.jpg"/>
                  <input type="image" class="kadr" name="mm4" src="'.$f[$kadr].$code.'m4.jpg"/>
                  <div>w <input type="text"  name="w" value="300" size="2" />
                       h <input type="text"  name="h" value="180" size="2" />
                       x <input type="text"  name="y" value="10"  size="2" />
                       y <input type="text"  name="x" value="10"  size="2" />
                       <button name="change">change</button></div>
                       <div>('.$numb.') '.$glob{'1_0_0'}.'</div>
                       <div>'.$glob{'1_1_0'}.'('.$glob{'3_0_0'}.')</div>'
        }
        $pics .= $i[13].'imgs'.$i[14].$p.
                 $i[13].'foto'.$i[14].$k.
                 $i[15];
        for my $x (5..6) {
            $pics .= $i[12].'bill'.$i[14];
            for my $y (0..3) {
                 $pics .= $i[0].$i[1].'image'.
                          $i[4].$dba->[$numb][$x][$y][1].
                          $i[5].$f[3].$dba->[$numb][$x][$y][1].$i[7].$i[8].
                          $dba->[$numb][$x][$y][2].$i[10].$i[11]
                           if $dba->[$numb][$x][$y][1]
            }
            $pics .= $i[15];      
        }
        $pics .= $i[15];
 
        if ($find->[0]) {
            $pics .= '<div id="imgsf">';
            for (0..$#{$find}) {
                my $next = $find->[$_];
                $pics .= $i[0].$i[1].'image'.
                    $i[2].'image'.
                    $i[4].'nn'.($next).
                    $i[5].$f[6].$dba->[$next][0][0].'p2'.$i[6].
                    $i[8].$dba->[$next][1][0].
                    $i[10].$i[11];                 
            }
        }
        else {
            $pics .= '<div id="imgsk">';
            for (1..$dba->[$numb][0][3]) {
                my $image = Image::Magick->new;
	            $image->Read($f[0].$f[6].$code.'k'.$_.'.jpg');
                my ($w, $h) = $image->Get('width', 'height');
                $pics .= $i[12].'dims'.$i[14].
                         $i[1].'checkbox'.
                         $i[2].'chek'.
                         $i[4].'kad'.$_.$i[14].
                         '('.$_.') '.$w.'x'.$h.
                         $i[1].'image'.
                         $i[2].'kads'.
                         $i[4].'kk'.$_.
                         $i[5].$f[6].$code.'k'.$_.$i[6].
                         $i[15];
            }            
        }
        $pics .= '<hr></div><div id="imgsf">';
        if ($mail->[0]) {
            for (0..$#{$mail}) {
                my $next = $mail->[$_];
                $pics .= $i[0].$i[1].'image'.
                         $i[2].'image'.
                         $i[4].$next.
                         $i[5].$f[4].$next.$i[6].
                         $i[8].$next.
                         $i[10].$i[11].
                         $i[1].'checkbox'.
                         $i[2].'chekit'.
                         $i[4].'ff'.$next.'ff'.$i[14];              
            }
            $pics .= '<hr>';
            for (0..$#{$imdb}) {
                my $next = $imdb->[$_];
                $pics .= $i[0].$i[1].'image'.
                         $i[2].'image'.
                         $i[4].$next.
                         $i[5].$f[4].$next.$i[6].
                         $i[8].$next.
                         $i[10].$i[11].
                         $i[1].'checkbox'.
                         $i[2].'chekit'.
                         $i[4].$next.$i[14];              
            }
            $pics .= $i[0].$i[1].'image'.
             $i[3].'search'.
             $i[4].'find'.
             $i[5].$f[3].'chek'.$i[7].
             $i[8].'insert'.
             $i[10].$i[11];
        }
        else {
            $pics .= $crew;
        }
        $pics .= '</div></div></div>';

        for ('del', 'send', 'lt', 'rt') {
            $pics .= $i[0].$i[1].'image'.$i[2].'del'.$i[4].$_.$i[5].$f[3].$_.$i[7].$i[11]
        }            
    }
    elsif ($snip->[1][$bnumb][1] == 1) {
        my $post = 'blank';
        if ($bnumb == 1) {
            $post = $dba->[$numb][0][0] if $dba->[$numb][2][0] == 1;
            $name = $dba->[$numb][1][1];
            $path = $f[6].$post.$i[6];
        }
        elsif ($bnumb == 2 or $bnumb == 3) {
            $post = $dba->[$numb][0][1];
            $name = $dba->[$numb][1][0];
            $path = $f[3].$post.$i[7];
        }
        $crew .= $i[0].$i[1].'image'.
                 $i[2].'post'.
                 $i[4].'pp'.($numb).
                 $i[5].$path.
                 $i[8].$name.$i[10].$i[11];
        my $dba8 =  LoadFile($base.8);
        my $dba4 =  LoadFile($base.4);
        for my $x (1..$#{$dba8}) {
            for my $y (7..12) {
                for my $z (0..$dba8->[0][$y][2]) {
                    if ($dba8->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                        $crew = $crew.
                        '<a title="'.$dba8->[$x][1][1].'">
                        <input class="image'.'" type="image" name="'.$dba8->[$x][0][0].
                        '" src="/images/images/'.$dba8->[$x][0][0].'p2.jpg"></a>'
                    }
                }
            }  
        }
        for my $x (1..$#{$dba4}) {
            for my $y (7..12) {
                for my $z (0..$dba4->[0][$y][2]) {
                    if ($dba4->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                        $crew = $crew.
                        '<a title="'.$dba4->[$x][1][1].'">
                        <input class="image'.'" type="image" name="'.$dba4->[$x][0][0].
                        '" src="/images/images/'.$dba4->[$x][0][0].'p2.jpg"></a>'
                    }
                }
            }  
        }
        $pics .= '<div id="imgsf">'.$crew.'</div></div>';   
        for ('lt', 'rt') {
            $pics .= $i[0].$i[1].'image'.$i[2].'del'.$i[4].$_.$i[5].$f[3].$_.$i[7].$i[11]
        }
    }
    else {
        my %glob = %$glob;
        for (1..$glob{'0_3_0'}) {
            $pics .= '<div class="dims"><input type="checkbox" class="chek" name="k'.$_.'"/>
                      <img style="width: 350px;" name="'.$_.'"src="/images/find/'.$_.'.jpg"/></div>';
        } 
    }
    $pics .= '</div>';
    if ($#{$dba} > 15) {
        my $x = 0;
        for (1..15) {
            if ($numb >= 15) {
                $next = $numb - ($_- 1);
            }
            elsif ($numb < 15) {
                if ($_ <= $numb) {
                    $next = $numb - ($_- 1);
                }
                else {
                    $next = ($#{$dba}-$x);
                    ++$x;
                }
            }
            if ($bnumb == 1) {
                $pic = 'blank' if $dba->[$next][2][0] == 0;
                $pic = $dba->[$next][0][0] if $dba->[$next][2][0] == 1;
                $name = $dba->[$next][1][1];
                $path = $f[6].$pic.$i[6];                
            }
            elsif ($bnumb == 8 or $bnumb == 4 or $bnumb == 5 or $bnumb == 10) {
                $pic = $dba->[$next][0][0];
                $name = $dba->[$next][1][1];
                $path = $f[6].$pic.'p2'.$i[6];
            }
            elsif ($bnumb == 2 or $bnumb == 3) {
                $pic  = $dba->[$next][0][1];
                $name = $dba->[$next][1][0];
                $path = $f[3].$pic.$i[7];
            }
		    $rigtp .= $i[12].'numb'.$i[14].$next.$i[15].
                      $i[0].$i[1].'image'.
                      $i[2].'image'.
                      $i[4].'nn'.($next).
                      $i[5].$path.
                      $i[8].$name.$i[10].$i[11]
	    }
    }
    return $panl.$form.$pics.'<div id="rcol">
                 <div id ="total">'.$#{$dba}.'</div>'.$rigtp.'</div>'
}
sub mini {
    my ($self, $numb, $param, $base, $basenumb, $mini, $geometry) = @_;
    my (@f, $checkk);
	my $dba = LoadFile($base.$basenumb);
	my $shem = LoadFile($base.0);
	push @f, $shem->[4][$_] for 0..6;
    my $code = $dba->[$numb][0][0];
	my $max  = $dba->[$numb][2][0];
	for (1..$max) {
		$checkk = $_ if $param->{'kad'.$_};
	}
    unlink glob "f[0].$f[4]*.*";
	my $image = Image::Magick->new;
	$image->Read($f[0].$f[6].$code.'k'.$checkk.'.jpg');
	$image->Crop(geometry=>$geometry);
    $image->Resize(width=>170, height=>100);
    $image->Write($f[0].$f[4].$code.'m'.$mini.'.jpg');
	for (1..4) {
        copy ($f[0].$f[6].$code.'m'.$_.'.jpg', $f[0].$f[4].$code.'m'.$_.'.jpg') if ($_ != $mini);
	}
    copy ($f[0].$f[6].$code.'k'.$checkk.'.jpg', $f[0].$f[4].$code.'k'.$mini.'.jpg');
	copy ($f[0].$f[6].$code.'k'.$mini.'.jpg', $f[0].$f[4].$code.'k'.$checkk.'.jpg');
	for (1..$max) {
        copy ($f[0].$f[6].$code.'k'.$_.'.jpg', $f[0].$f[4].$code.'k'.$_.'.jpg') if ($_ != $mini and $_ != $checkk);
	}
	return 4
}
sub change {
	my ($self, $numb, $base, $bnumb) = @_;
	my $dba = LoadFile($base.$bnumb);
	my @f;	
	my $shem = LoadFile($base.0);
	push @f, $shem->[4][$_] for 0..6;
	my $code = $dba->[$numb][0][0];
	my $max  = $dba->[$numb][2][0];
	for (0..4) {
        copy ($f[0].$f[4].$code.'m'.$_.'.jpg', $f[0].$f[6].$code.'m'.$_.'.jpg');
		copy ($f[0].$f[4].$code.'m'.$_.'.jpg', $f[0].$f[5].$code.'m'.$_.'.jpg');
	}
    for (1..$max) {
        copy ($f[0].$f[4].$code.'k'.$_.'.jpg', $f[0].$f[6].$code.'k'.$_.'.jpg');
		copy ($f[0].$f[4].$code.'k'.$_.'.jpg', $f[0].$f[5].$code.'k'.$_.'.jpg');
	}
}
sub person {
	my ($self, $base, $basenumb, $numb) = @_;
	my $dba = LoadFile($base.$basenumb);
	my $dba8 = LoadFile($base.8);
	my $dba4 = LoadFile($base.4);
	my @f;	
	my $shem = LoadFile($base.0);
	push @f, $shem->[3][$_] for 0..6;
	my $code = $dba->[$numb][0][0];
	my $image = Image::Magick->new;
	$image->Read($f[0].$f[4].'00.jpg');
    $image->Resize(width=>170, height=>240);
	$image->Write($f[0].$f[5].$code.'.jpg');
	$image->Write($f[0].$f[6].$code.'.jpg');
	$dba->[$numb][2][0] = 1;
	my ($x, $y, $z);
	for $x (1..$#{$dba8}) {
		for $y (7..12) {
		    for $z (0..$#{$dba8->[$x][$y]}) {
				if ($dba8->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                    $dba8->[$x][$y][$z][3] = $dba8->[$x][$y][$z][0]						
				}
		    }
		}
	}
	for $x (1..$#{$dba4}) {
		for $y (7..12) {
		    for $z (0..$#{$dba4->[$x][$y]}) {
				if ($dba4->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                    $dba4->[$x][$y][$z][3] = $dba4->[$x][$y][$z][0]						
				}
		    }
		}
	}
	DumpFile($base.$basenumb, $dba);
	DumpFile($base.8, $dba8);
	DumpFile($base.4, $dba4);
	return $dba
}
__PACKAGE__->meta->make_immutable;

1;
