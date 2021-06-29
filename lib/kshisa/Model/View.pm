package kshisa::Model::View;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use File::Copy;
use utf8;

extends 'Catalyst::Model';

=head1 NAME

kshisa::Model::View - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=encoding utf8

=head1 AUTHOR

Marat Hakimov

=head1 LICENSE

This library is not free software. You can't redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub view {
    my ($self, $numb, $bnumb, $glob, $kadr, $find, $mail, $imdb, $title, $param, $base, $imgs) = @_;
    my (@f, @n, @d, @t, @s, @o,  @i, $crew, $form, $rigtp, $nav, $select, $area);
   	my $dba  = LoadFile($base.$bnumb); 
    my $snip = LoadFile($base.'0');
    my $shem = $dba->[0];
    push @d, $shem->[$_] for 0..$#{$shem};
    my %glob = %$glob;
    my $code = $glob{'0_0_0'};

    push @f, $snip->[4][$_]    for 0..$#{$snip->[4]};
    push @n, $snip->[5][$_]    for 0..$#{$snip->[5]};
    push @i, $snip->[0][0][$_] for 0..$#{$snip->[0][0]};
    push @s, $snip->[0][1][$_] for 0..$#{$snip->[0][1]};
    push @o, $snip->[0][2][$_] for 0..$#{$snip->[0][2]};
    push @t, $snip->[0][3][$_] for 0..$#{$snip->[0][3]};

    my $panl = $i[1].'hidden'.$i[4].'idr'.$i[16].$numb.$i[14].
               $i[1].'hidden'.$i[4].'idb'.$i[16].$bnumb.$i[14].
               $i[1].'hidden'.$i[4].'tit'.$i[16].$title.$i[14];
   
    $panl .= $o[4].'files'.$i[3].'addr" onchange="subm1()"/>';        
    for (1..$#{$snip->[1]}) {
        if ($snip->[1][$_][0]) {
	        $panl .= $o[6].$_.'"';
            if ($_ eq $bnumb) {
                $panl .= $o[12];
            }
            $panl .= $o[7].$snip->[1][$_][0].' ('.$snip->[1][$_][2].')'.$o[8];            
        }
    }
    $panl .= $o[9];

    if ($glob{'0_0_0'}) {
        if ($mail->[0]) {
            $panl .= $i[13].'tit'.$i[14].$title.$i[15];
            $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'find'.$i[5].$f[0].'chek'.$i[7].
                     $i[8].'found'.$i[10].$i[11];
        }
        else {
            $panl .= $i[1].'text'.$i[3].'address'.$i[4].'Address"'.$i[14];
            $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'sch'.$i[5].$f[0].'rt'.$i[7].
                     $i[8].'search'.$i[10].$i[11];        
        }
    }        
    else {
        $panl .= $i[13].'tit'.$i[14].$title.$i[15];
        $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'insert'.$i[5].$f[0].'chek'.$i[7].
                 $i[8].'insert'.$i[10].$i[11];
    }        
    $panl .= $i[13].'Clock'.$i[14]. # Clock
             $i[13].'timer'.$i[14].
             $i[13].'hours'.$i[14].$i[15].
             $i[13].'min'  .$i[14].$i[15].
             $i[13].'sec'  .$i[14].$i[15].$i[15].
             $i[13].'Date' .$i[14].$i[15].
             $i[15];
    for ('del', 'lt', 'rt', 'send') {                                   #NAVIGATION
        $nav .= $i[0].$i[1].'image'.$i[2].'del'.$i[4].$_.$i[5].$f[0].$_.$i[7].$i[11]
    }
    $panl .= $i[13].'nav'.$i[14].$nav.$i[15];
    $panl .= $o[4].''.$i[3].'addr" onchange="subm2()"/>';        
    for (1..$#{$snip->[5]}) {
        if ($snip->[5][$_][0]) {
	        $panl .= $o[6].$_.'"';
            if ($_ eq $bnumb) {
                $panl .= $o[12];
            }
            $panl .= $o[7].$snip->[5][$_][0].$o[8];            
        }
    }
    $panl .= $o[9];                    
    if ( $glob{'0_0_0'} =~ /^\d+f(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/ ) { # TIMESTAMP
        $form .= $3.'.'.$2.'.20'.$1.'   '.$4.'::'.$5.'::'.$6.$s[8].$s[9];
    }

    for my $x (0..$#{$shem}) {
        my $flag = 0;
        my ($a, $b) = ($1, $2) if $d[$x][2] =~ /^(\d+)_(\d+)$/;
        for my $y (0..$a) {
            for my $z (0..$b) {
                if (!$code) {
                    if ($d[$x][1] == 5) {
                        $form .= $t[0].$t[1].
                        $d[$x][5].' ('.($y+1).')'.
                        $t[8].$t[9].$t[0].$t[1].$t[5].
                        $x.'_'.$y.'_'.$z.$t[6].
                        $glob{$x.'_'.$y.'_'.$z}.$t[7].$t[8].$t[9];
                    }
                    else {               
                        $form .= $s[0].$s[1].$i[12].'label1'.$i[14].$d[$x][5];
                        $form .= ' ('.($y+1).')' if $a != 0;
                        $form .= $i[15].$s[5].$x.'_'.$y.'_'.$z.$s[6].
                        $glob{$x.'_'.$y.'_'.$z}.$s[7].$s[8].$s[9]
                    }
                }
                else {              
                    if ($d[$x][1] == 0) {
                        $form .= $s[0].$s[1].$s[2];
                        if ($x == 0 && $y == 3) {
                            $form .= 'bb'.$x.'_'.$y.'_'.$z.'_'.$d[$x][1].$s[3].'images';
                        }
                        else {
                            $form .= 'bb'.$x.'_'.$y.'_'.$z.'_'.$d[$x][1].$s[3].$d[$x][5];
                            $form .= '  ('.($y+1).')' if $a != 0;          
                        }
                        $form .= $s[4].$s[5].$x.'_'.$y.'_'.$z.$s[6].
                                 $glob{$x.'_'.$y.'_'.$z}.$s[7].$s[8].$s[9];
                    }
                    elsif ($d[$x][1] == 2 or $d[$x][1] == 3) {
                        my $dset = LoadFile($base.($x-3));
                        if ( $glob{$x.'_'.$y.'_'.$z} && length($glob{$x.'_'.$y.'_'.$z}) > 0 ) {
                            $select .= $o[0].$o[1].'bb'.$x.'_'.$y.'_'.$z.'_2'.
                                        $o[2].$d[$x][5].' ('.($y+1).')'.
                                        $o[3].$o[4].$x.'_'.$y.'_'.$z.$o[5].
                                        $o[6].$o[7];
	                                    for my $list (1..$#{$dset}) {
		                                    $select .= $o[6].$dset->[$list][0][1];
                                            if ($glob{$x.'_'.$y.'_'.$z} && 
                                                $dset->[$list][0][$z] eq $glob{$x.'_'.$y.'_'.$z}) {
                                                    $select .= $o[12]
                                            }
			                                 $select .= $o[7].$dset->[$list][1][0].$o[8];
			                            } 
			                            $select .= $o[8].$o[9].$o[10].$o[11]                        
                        }
                        elsif ($flag == 0) {
                            $select .= $o[0].$o[1].'bb'.$x.'_'.$y.'_'.$z.'_2'.
                                        $o[2].$d[$x][5].' ('.($y+1).')'.
                                        $o[3].$o[4].$x.'_'.$y.'_'.$z.$o[5].
                                        $o[6].$o[7];
	                                    for my $list (1..$#{$dset}) {
		                                    $select .= $o[6].$dset->[$list][0][1].
                                            $o[7].$dset->[$list][1][0].$o[8]
      			                        } 
			                            $select .= $o[8].$o[9].$o[10].$o[11];
                                        $flag = 1;
                        }
                    }
                    elsif ($d[$x][1] == 4) {
                        if ($glob{$x.'_'.$y.'_0'} && length($glob{$x.'_'.$y.'_0'}) > 0 ) {
                            my $name = '----';
                            $name = $d[$x][5].' ('.($y+1).')' if $z == 0;
                            $name = 'Имя' if $z == 1 or $z == 2;
                            $name = 'name'  if $z == 2;
                            $name = 'role' if $z == 3  && $x == 8;
                            my $val = '';
                            $val = $glob{$x.'_'.$y.'_'.$z} if $z == 0 or $z == 1 or $z == 2 or $z == 3;                     
                            $form .= $s[0].$s[1].$s[2].'bb'.$x.'_'.$y.'_'.$z.'_1'.
                                     $s[3].$name.$s[4].$s[5].$x.'_'.$y.'_'.$z.
                                     $s[6].$val.$s[7].$s[8].$s[9];

                        }
                        elsif ($flag == 0) {
                            if ($z==0) {
                                $form .= $s[0].$s[1].$s[2].'bb'.$x.'_'.$y.'_'.$z.'_1'.
                                         $s[3].$d[$x][5].' ('.($y+1).')'.$s[4].$s[5].
                                         $x.'_'.$y.'_'.$z.$s[6].$s[7];

                                $form .= $s[8].$s[8].$s[9]
                            }
                            $flag = 1;
                        }
                    }
                    elsif ($d[$x][1] == 5) {
                        $area .= $t[0].$t[1].$t[2].'bb'.$x.'_'.$y.'_'.$z.'_0'.
                                 $t[3].$d[$x][5].' ('.($y+1).')'.
                                 $t[4].$t[8].$t[9].$t[0].$t[1].$t[5].
                                 $x.'_'.$y.'_'.$z.$t[6];
                        $area .= $glob{$x.'_'.$y.'_'.$z} if $glob{$x.'_'.$y.'_'.$z};
                        $area .= $t[7].$t[8].$t[9];
                    }
                }
            }
        }
    }
    my $pics = $i[13].'pics'.$i[14];
    my ($pic, $next, $name, $path, $old);
    if ($code && $snip->[1][$bnumb][1] == 0) {
        for my $x (7..12) {                           # PORTRETS OF CAST
            my $flag = 0;
            if ( $d[$x][2] =~ /^(\d+)_(\d+)$/ ) {
                ($a, $b) = ($1, $2);
            }
            for my $y (0..$a) {
                if ($glob{$x.'_'.$y.'_0'}) {
                    $crew .= $i[0].$i[1].'image'.
                         $i[2].'port'.
                         $i[4].$glob{$x.'_'.$y.'_0'};
                    if (-e $imgs.'1/'.$glob{$x.'_'.$y.'_0'}.'p1.jpg'){
                        $crew .= $i[5].$f[1].$glob{$x.'_'.$y.'_0'}.'p1';
                    }
                    else {
                        $crew .= $i[5].$f[1].'blank';
                    }
                    $crew .= $i[6].$i[8].
                             $dba->[0][$x][5].' ('.($y+1).')'.
                             $i[9].$glob{$x.'_'.$y.'_1'}.
                             $i[9].$glob{$x.'_'.$y.'_2'}.
                             $i[10].$i[11];
                }
                elsif ($flag == 0) {
                    $crew .= $i[17].$i[5].$f[1].'buts'.$i[7];
                    $flag = 1;
                }
            }
        }
        $form = $t[10].$form.$select.$area.$t[11];
 
        if ($find->[0]) {       #FIND MODE
            $pics .= $i[20];
            for (0..$#{$find}) {
                my ($name, $file, $code, $titl);
                if ($find->[$_][0] =~ /(\d+f((\d+)f\d+))/) {
                    $name = $1;
                    $code = $2;
                    $file = $3;
                }
                ;
                $pics .= $i[0].$i[1].'image'.
                         $i[2].
                         $i[4].$name.
                         $i[5].$f[$file].$code.'p2'.$i[6].
                         $i[8].$find->[$_][1].
                         $i[10].$i[11];                 
            }
            $pics .= $i[20];
        }
        if ($mail->[0]) {
            $pics .= $i[20].$i[12].$i[14].'mail'.$i[15];
            for (0..$#{$mail}) {
                my $next = $mail->[$_][0];
                my $titl = $mail->[$_][1];
                $pics .= $i[0].$i[17].$i[2].
                         $i[4].$next.
                         $i[5].$n[0].$next.$i[6].
                         $i[8].$titl.
                         $i[10].$i[11].
                         $i[1].'checkbox'.
                         $i[2].'chekit'.
                         $i[4].'ff'.$next.'ff'.$i[14];              
            }
        }
        if ($imdb->[0]) {
            $pics .= $i[20].$i[12].$i[14].'imdb'.$i[15];
            for (0..$#{$imdb}) {
                my $next = $imdb->[$_][0];
                my $titl = $imdb->[$_][1];
                if (-e $imgs.'find/'.$next.'.jpg') {
                    $pics .= $i[0].$i[17].$i[2].
                         $i[4].$next.
                         $i[5].$n[0].$next.$i[6].
                         $i[8].$titl.
                         $i[10].$i[11].
                         $i[1].'checkbox'.
                         $i[2].'chekit'.
                         $i[4].$next.$i[14];                    
                }
            }
            $pics .= $i[20];
        }
        my $p;
        if ($kadr =~ /kk(\d+)/){                                                          # TVset
            $p .= $i[13].'shot'.$i[14].$i[1].'image'.$i[5].$f[$bnumb].$code.'k'.$1.$i[6].$i[14]
        }
        elsif ($kadr =~ /(\d+f\d+)/){
           $p .= $i[13].'shot'.$i[14].
           '<video width="400" height="300" controls="controls" autoplay="autoplay">
                <source src="/images/video/'.$kadr.'.mp4" type=\'video/mp4; codecs="avc1.42E01E, mp4a.40.2"\'>
            </video>'
        }
        else {
            $p .= $i[13].'rating" data-rating="'.($glob{'2_0_0'}/10).$i[14]. 
                  $i[1].'image'.$i[3].'post'.$i[4].'post'.$i[5].$f[$bnumb].$code.'p2'.$i[6].$i[15].
                  $i[13].'foto'.$i[14];
            if ($kadr =~ /\d+/) {
                $p .= $i[1].'image'.$i[2].'kadr'.$i[4].'mm'.$_.$i[5].$f[$kadr].$code.'m'.$_.$i[6] for 1..4;
            }
            else {
                 $p .= $i[1].'image'.$i[2].'kadr'.$i[4].'mm'.$_.$i[5].$n[0].$code.'m'.$_.$i[6] for 1..4;
            }
            $p .= $i[13].'title1'.$i[14].$glob{'1_0_0'}.$i[15].
                  $i[13].'title2'.$i[14].$glob{'1_1_0'}.'('.$glob{'3_0_0'}.')'.$i[15];
        }
        $pics .= $i[13].'imgs'.$i[14].$p.$i[15];
        my ($a, $b) = ($1, $2) if $glob{'2_0_0'} =~ /^(\d)(\d)$/;
        $pics .= $i[13].'reit'.$i[14].$i[17].
             'imdb'.$i[5].$f[0].'imdb'.$i[7].$i[12].'numb'.$i[14].($a.','.$b).$i[15].$i[15];
        for my $x (5..6) {
            $pics .= $i[12].'bill'.$i[14];
            for my $y (0..3) {
                $pics .= $i[0].$i[1].'image'.
                          $i[4].$dba->[$numb][$x][$y][0].
                          $i[5].$f[$x-3].$dba->[$numb][$x][$y][1].$i[7].$i[8].
                          $dba->[$numb][$x][$y][2].$i[10].$i[11]
                           if $dba->[$numb][$x][$y][1]
            }
            $pics .= $i[15];      
        }
        $pics .= $i[13].'dime'.$i[14];        
        $pics .= $i[15].$i[13].'imgsf'.$i[14];
        $pics .= $i[20].$i[1].'text'.$i[4].'imgs'.$i[3].'images'.$i[16].$param->{'imgs'}.$i[14];
        $pics .= $s[2].'images'.$i[3].'img'.$i[14].'images'.$s[4];
        my @dime = ('w', 'h', 'x', 'y');
        my @valu = (300, 180, 10, 10);
        for (0..3) {
            $pics .=' '.$dime[$_].' '.
            $i[1].'text'.$i[4].$dime[$_].$i[16].$valu[$_].'" size="2"'.$i[14];
            }
        $pics .= ' '.$s[2].'change'.$i[14].'change'.$s[4].$i[15];
        
        for (1..$dba->[$numb][0][3]) {
            my $image = Image::Magick->new;
            $image->Read($imgs.$bnumb.'/'.$code.'k'.$_.'.jpg');
            my ($w, $h) = $image->Get('width', 'height');
            $pics .= $i[12].'dims'.$i[14].
                     $i[1].'checkbox'.
                     $i[2].'chek'.
                     $i[4].'kad'.$_;
            if ($param->{'kad'.$_} &&  ($param->{'mm1.x'} or $param->{'mm2.x'}
                                 or $param->{'mm3.x'} or $param->{'mm4.x'})) {
                $pics .= '" checked="checked'
            }
            $pics .= $i[14].
                    '('.$_.') '.$w.'x'.$h.
                      $i[1].'image'.
                      $i[2].'kads'.
                      $i[4].'kk'.$_.
                      $i[5].$f[$bnumb].$code.'k'.$_.$i[6].
                      $i[15];
            }            
        $pics .= $i[20].$i[15].$i[15];
    }
    elsif ($snip->[1][$bnumb][1] == 1) {                            
        $form = $i[13].'data'.$i[14].$t[10].$form.$t[11].$i[15];
        my $pers;
        my $maps = '';
        my $post = 'blank';
        if ($bnumb == 1) {                            # PEOPLE MODE
            $post = $dba->[$numb][0][0].'p2' if $dba->[$numb][2][0] == 1;
            $name = $dba->[$numb][1][1];
            $path = $f[1].$post.$i[6];
            my @time;
            ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
            $old = ($dba->[$numb][3][1] || ($time[5]+1900)) - $dba->[$numb][3][0];
            for my $n (7..11) {
                my $file = LoadFile($base.$n);
                for my $x (1..$#{$file}) {
                    my $prof;
                    for my $y (7..12) {
                        for my $z (0..$file->[0][$y][2]-1) {
                            if ($file->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                                $prof .= $i[9].$file->[0][$y][5];

                            }
                        }
                    }
                    if (length($prof) > 0) {
                        $pers .= $i[0].$i[1].'image'.
                        $i[4].$file->[$x][0][0].
                        $i[5].$f[$n].$file->[$x][0][0].'p2'.$i[6].
                        $i[8].$file->[$x][1][0].'('.$file->[$x][3][0].')'.
                        $prof.$i[10].$i[11];                     
                    }
                }            
            }
        }
        elsif ($bnumb == 2 or $bnumb == 3) {
            $post = $dba->[$numb][0][1];
            $name = $dba->[$numb][1][0];
            $path = $f[$bnumb].$post.$i[7];
            $maps = $i[0].$i[17].$i[2].'post'.$i[5].$f[2].$dba->[$numb][0][0].$i[7].
                    $i[8].$dba->[$numb][1][0].$i[9].$i[11];
        }
        $pers .= $i[0].$i[1].'image'.$i[2].'post'.$i[4].'pp'.($numb).$i[5].
                    $path.$i[8].$name.$i[9].$old.$i[10].$i[11].$maps;

        $pics .= $i[13].'imgsf'.$i[14].$pers.$i[15].$i[15];   
    }
    else {                                                                 # FIND MODE
        $form = $i[13].'data'.$i[14].$t[10].$form.$t[11].$i[15];
        for (1..$glob{'0_3_0'}) {
            $pics .= $i[12].'dims'.$i[14].
                      $i[1].'checkbox'.$i[2].'chek'.$i[4].'k'.$_.$i[14].
                      $i[17].$i[4].$_.$i[5].$n[0].$_.$i[6].$i[15];
        } 
    }
    if ($code && $#{$dba} > 15) {
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
                $pic = $dba->[$next][0][0].'p1' if $dba->[$next][2][0] == 1;
                $name = $dba->[$next][1][1];
                $path = $f[1].$pic.$i[6];                
            }
            elsif ($bnumb == 2 or $bnumb == 3) {
                $pic  = $dba->[$next][0][1];
                $name = $dba->[$next][1][0];
                $path = $f[$bnumb].$pic.$i[7];
            }            
            else {
                $pic = $dba->[$next][0][0];
                $name = $dba->[$next][1][1].'('.$dba->[$next][3][0].')';
                $path = $f[$bnumb].$pic.'p1'.$i[6];
            }
		    $rigtp .= $i[12].'numb'.$i[14].$next.$i[15].
                      $i[0].$i[1].'image'.
                      $i[2].'image'.
                      $i[4].$pic.
                      $i[5].$path.
                      $i[8].$name.$i[10].$i[11]
	    }
    }

    return $panl, $crew, $form, $pics, $rigtp
}
sub mini {
    my ($self, $numb, $param, $base, $bnumb, $mini, $geometry, $home) = @_;
    my (@f, @n, $checkk);
	my $dba = LoadFile($base.$bnumb);
    my $snip  = LoadFile($home.'/Base/0');
    push @f, $snip->[4][$_]    for 0..$#{$snip->[4]};
    push @n, $snip->[5][$_]    for 0..$#{$snip->[5]};
    my $code = $dba->[$numb][0][0];
	my $max  = $dba->[$numb][0][3];
	for (1..$max) {
		$checkk = $_ if $param->{'kad'.$_};
	}
    #unlink glob "$home.$n[0]*.*";
	my $image = Image::Magick->new;
	$image->Read($home.$f[$bnumb].$code.'k'.$checkk.'.jpg');
	$image->Crop(geometry=>$geometry);
    $image->Resize(width=>170, height=>100);
    $image->Write($home.$n[0].$code.'m'.$mini.'.jpg');
	for (1..4) {
        copy ($home.$f[$bnumb].$code.'m'.$_.'.jpg', $home.$n[0].$code.'m'.$_.'.jpg') if ($_ != $mini);
	}
    copy ($home.$f[$bnumb].$code.'k'.$checkk.'.jpg', $home.$n[0].$code.'k'.$mini.'.jpg');
	copy ($home.$f[$bnumb].$code.'k'.$mini.'.jpg', $home.$n[0].$code.'k'.$checkk.'.jpg');
	for (1..$max) {
        copy ($home.$f[$bnumb].$code.'k'.$_.'.jpg', $home.$n[0].$code.'k'.$_.'.jpg') if ($_ != $mini and $_ != $checkk);
	}
}
sub change {
	my ($self, $numb, $base, $bnumb, $home) = @_;
	my $dba = LoadFile($base.$bnumb);
    my $snip  = LoadFile($home.'/Base/0');    
    my (@f, @n);	
    push @f, $snip->[4][$_]    for 0..$#{$snip->[4]};
    push @n, $snip->[5][$_]    for 0..$#{$snip->[5]};
    my $code = $dba->[$numb][0][0];
	my $max  = $dba->[$numb][0][3];
    for (0..4) {
        copy ($home.$n[0].$code.'m'.$_.'.jpg', $home.$f[$bnumb].$code.'m'.$_.'.jpg');
	}
    for (1..$max) {
        copy ($home.$n[0].$code.'k'.$_.'.jpg', $home.$f[$bnumb].$code.'k'.$_.'.jpg');
	}
}
sub person {
	my ($self, $base, $bnumb, $numb, $home) = @_;
	my $dba = LoadFile($base.$bnumb);
    my $snip = LoadFile($base.0);
	my (@f, @n);	
    push @f, $snip->[4][$_]    for 0..$#{$snip->[4]};
    push @n, $snip->[5][$_]    for 0..$#{$snip->[5]};
	my $code = $dba->[$numb][0][0];
    my $image = Image::Magick->new;
    $image->Read($home.$n[0].'00.jpg'); 
    $image->Resize(width=>170, height=>240);
    $image->Write($home.$f[$bnumb].$code.'p2.jpg');
	$image->Write($home.$n[0].'p2.jpg');
	$image->Resize(width=>85, height=>120);
    $image->Write($home.$f[$bnumb].$code.'p1.jpg');
	$image->Write($home.$n[0].'p1.jpg');
	$dba->[$numb][2][0] = 1;
	DumpFile($base.$bnumb, $dba);
	return $dba
}
__PACKAGE__->meta->make_immutable;

1;
