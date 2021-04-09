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
    my ($self, $numb, $bnumb, $base, $dba, $glob, $kadr, $find, $mail, $imdb, $title, $param) = @_;
    my (@d, @t, @s, @o, @f, @i, $crew, $rigtp, $size, $nav, $navex, $cntr);
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
    push @i, $snip->[0][0][$_] for 0..20;
    push @s, $snip->[0][1][$_] for 0..9;
    push @o, $snip->[0][2][$_] for 0..12;
    push @t, $snip->[0][3][$_] for 0..14;

    my $hidd = $i[1].'hidden'.$i[4].'idr'.$i[16].$numb.$i[14].
               $i[1].'hidden'.$i[4].'idb'.$i[16].$bnumb.$i[14].
               $i[1].'hidden'.$i[4].'tit'.$i[16].$title.$i[14];
               
    my $panl = $i[13].'Logo'.$i[14].
               $i[1].'image'.$i[3].'logo'.$i[4].'logout'.$i[5].$f[3].'kshisa'.$i[7].
               $i[15];
    $panl .= $o[4].'files" id="addr" onchange="subm1()"/>';            
    for (1..$#{$snip->[1]}) {
        if ($snip->[1][$_][0]) {
	        $panl .= $o[6].$_.'"';
            if ($_ eq $bnumb) {
                $panl .= $o[12];
            }
            $panl .= $o[7].$snip->[1][$_][0].$o[8];            
        }
    }
    $panl .= $o[9];
    if ($glob{'0_0_0'}) {
        if ($mail->[0]) {
            $panl .= $i[13].'tit'.$i[14].$title.$i[15];
            $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'find'.$i[5].$f[3].'chek'.$i[7].
                     $i[8].'go...go...go'.$i[10].$i[11];
        }
        else {
            $panl .= $i[1].'text'.$i[3].'address'.$i[4].'Address" size="34'.$i[14];
            $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'sch'.$i[5].$f[3].'rt'.$i[7].
                     $i[8].'go...go...go'.$i[10].$i[11];        
        }
    }        
    else {
        $panl .= $i[13].'tit'.$i[14].$title.$i[15];
        $panl .= $i[0].$i[1].'image'.$i[3].'search'.$i[4].'insert'.$i[5].$f[3].'chek'.$i[7].
                 $i[8].'go...go...go'.$i[10].$i[11];
    }        
    $panl .= $i[13].'Clock'.$i[14]. # Clock
             $i[13].'timer'.$i[14].
             $i[13].'hours'.$i[14].$i[15].
             $i[13].'min'  .$i[14].$i[15].
             $i[13].'sec'  .$i[14].$i[15].$i[15].
             $i[13].'Date' .$i[14].$i[15].
             $i[15];
    $panl .= '<div id="weather">
              <a target="_blank" href="http://nochi.com/weather/kazan-4422"><img style="height:50px; width:138px;" 
              src="https://w.bookcdn.com/weather/picture/1_4422_1_20_babec2_320_ffffff_333333_08488D_1_ffffff_333333_0_6.png?scode=124&domid=589&anc_id=35927"  
              alt="booked.net"/></a>'.$i[15];
    
    my ($year, $month, $day, $hour, $select, $area);                               # DATE FROM BASE
    my $form = $s[0].$s[1].$glob{'0_0_0'}.$s[8].$s[9].$s[0].$s[1];
    if ( $glob{'0_0_0'} =~ /^\df(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/ ) {
        $form .= $3.'.'.$2.'.20'.$1.'   '.$4.'::'.$5.'::'.$6.$s[8].$s[9];
    }
    for my $x (0..$size) {
        my $flag = 0;
        ($a, $b) = ($1, $2) if $d[$x][2] =~ /^(\d+)_(\d+)$/;
        for my $y (0..$a) {
            for my $z (0..$b) {
                if (!$code) {
                    if ($d[$x][1] == 4) {
                        $form .= $t[0].$t[1].$t[2].
                        $t[3].$d[$x][0].' ('.($y+1).')'.
                        $t[4].$t[8].$t[9].$t[0].$t[1].$t[5].
                        $x.'_'.$y.'_'.$z.$t[6].
                        $glob{$x.'_'.$y.'_'.$z}.$t[7].$t[8].$t[9];
                    }
                    else {               
                        $form .= $s[0].$s[1].$i[12].'label1'.$i[14].$d[$x][0];
                        $form .= ' ('.($y+1).')' if $a != 0;
                        $form .= $i[15].$s[5].$x.'_'.$y.'_'.$z.$s[6].
                        $glob{$x.'_'.$y.'_'.$z}.$s[7].$s[8].$s[9]
                    }
                }
                else {              
                    if ($d[$x][1] == 1) {
                        $form .= $s[0].$s[1].$s[2];
                        if ($x == 0 && $y == 3) {
                            $form .= 'bb'.$x.'_'.$y.'_'.$z.'_5'.
                                      $s[3].'images';
                        }
                        else {
                            $form .= 'bb'.$x.'_'.$y.'_'.$z.'_0'.
                                      $s[3].$d[$x][0];
                            $form .= '  ('.($y+1).')' if $a != 0;          
                        }
                        $form .= $s[4].$s[5].$x.'_'.$y.'_'.$z.$s[6].
                                 $glob{$x.'_'.$y.'_'.$z}.$s[7].$s[8].$s[9];
                    }
                    elsif ($d[$x][1] == 2) {
                        my $dset = LoadFile($base.2);
                        if ( $glob{$x.'_'.$y.'_'.$z} && length($glob{$x.'_'.$y.'_'.$z}) > 0 ) {
                            $select .= $o[0].$o[1].'bb'.$x.'_'.$y.'_'.$z.'_2'.
                                        $o[2].$d[$x][0].' ('.($y+1).')'.
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
			                            $select .= $o[8].$o[9].$o[10]                        
                        }
                        elsif ($flag == 0) {
                            $select .= $o[0].$o[1].'bb'.$x.'_'.$y.'_'.$z.'_2'.
                                        $o[2].$d[$x][0].' ('.($y+1).')'.
                                        $o[3].$o[4].$x.'_'.$y.'_'.$z.$o[5].
                                        $o[6].$o[7];
	                                    for my $list (1..$#{$dset}) {
		                                    $select .= $o[6].$dset->[$list][0][1].
                                            $o[7].$dset->[$list][1][0].$o[8]
      			                        } 
			                            $select .= $o[8].$o[9].$o[10];
                                        $flag = 1;
                        }
                    }
                    elsif ($d[$x][1] == 3) {
                        if ($glob{$x.'_'.$y.'_0'} && length($glob{$x.'_'.$y.'_0'}) > 0 ) {
                            my $name = $d[$x][0].' ('.($y+1).')' if $z == 0;
                            $name = 'name' if $z == 1 or $z == 2;
                            $name = 'role' if $z == 3;
                            my $val = '';
                            $val = $glob{$x.'_'.$y.'_'.$z} if $z == 1 or $z == 2 or $z == 3;                     
                            $form .= $s[0].$s[1].$s[2].'bb'.$x.'_'.$y.'_'.$z.'_1'.
                                     $s[3].$name.$s[4].$s[5].$x.'_'.$y.'_'.$z.
                                     $s[6].$val.$s[7].$s[8].$s[9];

                        }
                        elsif ($flag == 0) {
                            if ($z==0) {
                                $form .= $s[0].$s[1].$s[2].'bb'.$x.'_'.$y.'_'.$z.'_1'.
                                         $s[3].$d[$x][0].' ('.($y+1).')'.$s[4].$s[5].
                                         $x.'_'.$y.'_'.$z.$s[6].$s[7];

                                $form .= $s[8].$s[8].$s[9]
                            }
                            $flag = 1;
                        }
                    }
                    elsif ($d[$x][1] == 4) {
                        $area .= $t[0].$t[1].$t[2].'bb'.$x.'_'.$y.'_'.$z.'_0'.
                                 $t[3].$d[$x][0].' ('.($y+1).')'.
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
                    if (-e $f[0].$f[6].$glob{$x.'_'.$y.'_0'}.'.jpg'){
                        $crew .= $i[5].$f[6].$glob{$x.'_'.$y.'_0'};
                    }
                    else {
                        $crew .= $i[5].$f[6].'blank';
                    }
                    $crew .= $i[6].$i[8].
                             $dba->[0][$x][5].' ('.($y+1).')'.
                             $i[9].$glob{$x.'_'.$y.'_1'}.
                             $i[9].$glob{$x.'_'.$y.'_2'}.
                             $i[10].$i[11];
                }
                elsif ($flag == 0) {
                    $crew .= $i[17].$i[5].$f[6].'buts'.$i[7];
                    $flag = 1;
                }
            }
        }
        $form = $t[10].$form.$select.$area.$t[11];

        if ($find->[0]) {
            $pics .= $i[20];
            for (0..$#{$find}) {
                my $next = $find->[$_];
                $pics .= $i[0].$i[1].'image'.
                         $i[2].'image'.
                         $i[4].'nn'.($next).
                         $i[5].$f[6].$dba->[$next][0][0].'p2'.$i[6].
                         $i[8].$dba->[$next][1][0].
                         $i[10].$i[11];                 
            }
            $pics .= $i[20];
        }
        if ($mail->[0]) {
            $pics .= $i[20].$i[12].$i[14].'mail'.$i[15];
            for (0..$#{$mail}) {
                my $next = $mail->[$_][0];
                my $titl = $mail->[$_][1];
                $pics .= $i[0].$i[17].$i[2].'image'.
                         $i[4].$next.
                         $i[5].$f[4].$next.$i[6].
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
                my $path = $f[0].$f[4];
                if (-e $path.$next.'.jpg') {
                    $pics .= $i[0].$i[17].$i[2].'image'.
                         $i[4].$next.
                         $i[5].$f[4].$next.$i[6].
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
            $p .= $i[13].'shot'.$i[14].$i[1].'image'.$i[5].$f[6].$code.'k'.$1.$i[6].$i[14]
        }
        elsif ($kadr =~ /(\d+f\d+)/){
           $p .= $i[13].'shot'.$i[14].
           '<video width="400" height="300" controls="controls" autoplay="autoplay">
                <source src="/images/video/'.$kadr.'.mp4" type=\'video/mp4; codecs="avc1.42E01E, mp4a.40.2"\'>
            </video>'
        }
        else {
            $p .= $i[13].'rating" data-rating="'.($glob{'2_0_0'}/10).$i[14]. 
                  $i[1].'image'.$i[3].'post'.$i[4].'post'.$i[5].$f[6].$code.'p2'.$i[6].
                  $i[12].'numb'.$i[14].'IMDb: '.($glob{'2_0_0'}/10).$i[15].$i[15].
                  $i[13].'foto'.$i[14];
            for (1..4) {
                $p .= $i[1].'image'.$i[2].'kadr'.$i[4].'mm'.$_.$i[5].$f[$kadr].$code.'m'.$_.$i[6];
            }
            $p .= $i[13].'dime'.$i[14];
            my @dime = ('w', 'h', 'y', 'x');
            my @valu = (300, 180, 10, 10);
            for (0..3) {
                $p .= ' '.$dime[$_].' '.
                $i[1].'text'.$i[4].$dime[$_].$i[16].$valu[$_].'" size="2"'.$i[14];
            }
            $p .= ' '.$i[18].$i[4].'change'.$i[14].'change'.$i[19].$i[15].
            $i[13].'title1'.$i[14].$glob{'1_0_0'}.$i[15].
            $i[13].'title2'.$i[14].$glob{'1_1_0'}.'('.$glob{'3_0_0'}.')'.$i[15];
        }
        $pics .= $i[13].'imgs'.$i[14].$p.$i[15];
        for my $x (5..6) {
            $pics .= $i[12].'bill'.$i[14];
            for my $y (0..3) {
                 $pics .= $i[0].$i[1].'image'.
                          $i[4].$dba->[$numb][$x][$y][0].
                          $i[5].$f[3].$dba->[$numb][$x][$y][1].$i[7].$i[8].
                          $dba->[$numb][$x][$y][2].$i[10].$i[11]
                           if $dba->[$numb][$x][$y][1]
            }
            $pics .= $i[15];      
        }
        $pics .= $i[15].$i[13].'imgsf'.$i[14];
        for (1..$dba->[$numb][0][3]) {
            my $image = Image::Magick->new;
            $image->Read($f[0].$f[6].$code.'k'.$_.'.jpg');
            my ($w, $h) = $image->Get('width', 'height');
            $pics .= $i[12].'dims'.$i[14].
                     $i[1].'checkbox'.
                     $i[2].'chek'.
                     $i[4].'kad'.$_;
            if ($param->{'kad'.$_}) {
                $pics .= '" checked="checked'
            }
            $pics .= $i[14].
                    '('.$_.') '.$w.'x'.$h.
                      $i[1].'image'.
                      $i[2].'kads'.
                      $i[4].'kk'.$_.
                      $i[5].$f[6].$code.'k'.$_.$i[6].
                      $i[15];
            }            
        $pics .= '<hr>'.$i[15].$i[15];
        for ('del', 'send') {
             $navex .= $i[0].$i[1].'image'.$i[2].'del'.$i[4].$_.$i[5].$f[3].$_.$i[7].$i[11]
        }
        for ('lt', 'rt') {
            $nav .= $i[0].$i[1].'image'.$i[2].'del'.$i[4].$_.$i[5].$f[3].$_.$i[7].$i[11]
        }
        $cntr = $i[13].'nav'.$i[14].$navex.$i[15].
            $i[13].'tot'.$i[14].$#{$dba}.$i[15].
            '<button name="roles" 
            style="width:8%; height:10%; margin-top:14px;">roles</button>'.              
            $i[13].'nav'.$i[14].$nav.$i[15];
 
    }
    elsif ($snip->[1][$bnumb][1] == 1) {                            # PEOPLE MODE
        $form = $i[13].'data'.$i[14].$t[10].$form.$t[11].$i[15];
        my $maps = '';
        my $post = 'blank';
        if ($bnumb == 1) {
            $post = $dba->[$numb][0][0] if $dba->[$numb][2][0] == 1;
            $name = $dba->[$numb][1][1];
            $path = $f[6].$post.$i[6];
            my @time;
            ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
            $old = ($dba->[$numb][3][1] || ($time[5]+1900)) - $dba->[$numb][3][0];
        }
        elsif ($bnumb == 2 or $bnumb == 3) {
            $post = $dba->[$numb][0][1];
            $name = $dba->[$numb][1][0];
            $path = $f[3].$post.$i[7];
            $maps = $i[0].$i[17].$i[2].'post'.$i[5].$f[3].$dba->[$numb][0][0].$i[7].
                    $i[8].$dba->[$numb][1][0].$i[9].$i[11];
        }
        my $pers .= $i[0].$i[1].'image'.$i[2].'post'.$i[4].'pp'.($numb).$i[5].
                    $path.$i[8].$name.$i[9].$old.$i[10].$i[11].$maps;
		my @files = (8, 4, 5);
		for my $n (@files) {
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
                         $i[5].$f[6].$file->[$x][0][0].'p2'.$i[6].
                         $i[8].$file->[$x][1][0].'('.$file->[$x][3][0].')'.
                         $prof.$i[10].$i[11];                     
                }
            }            
        }
        $pics .= $i[13].'imgsf'.$i[14].$pers.$i[15].$i[15];   
    }
    else {                                                                 # FIND MODE
        $form = $i[13].'data'.$i[14].$t[10].$form.$t[11].$i[15];
        for (1..$glob{'0_3_0'}) {
            $pics .= $i[12].'dims'.$i[14].
                      $i[1].'checkbox'.$i[2].'chek'.$i[4].'k'.$_.$i[14].
                      $i[17].'style="width:350px;'.$i[4].$_.
                      $i[5].$f[4].$_.$i[6].$i[15];
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
                $pic = $dba->[$next][0][0] if $dba->[$next][2][0] == 1;
                $name = $dba->[$next][1][1];
                $path = $f[6].$pic.$i[6];                
            }
            elsif ($bnumb == 8 or $bnumb == 4 or $bnumb == 5 or $bnumb == 10) {
                $pic = $dba->[$next][0][0];
                $name = $dba->[$next][1][1].'('.$dba->[$next][3][0].')';
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
    my $root = $hidd.
               $i[12].'row'.$i[14].$cntr.$i[15].
               $i[12].'row'.$i[14].$panl.$i[15].
               $i[12].'row'.$i[14].
               $i[12].'col-1'.$i[14].$i[13].'pers'.$i[14].$crew.$i[15].$i[15].
               $i[12].'col-3'.$i[14].$form.$i[15].
               $i[12].'col-7'.$i[14].$pics.$i[15].
               $i[12].'col-1'.$i[14].$rigtp.$i[15].
               $i[15];

    return $root
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
    my $shem = LoadFile($base.0);
	my @f;	
	push @f, $shem->[4][$_] for 0..6;
	my $code = $dba->[$numb][0][0];
	my $image = Image::Magick->new;
	$image->Read($f[0].$f[4].'00.jpg');
    
    $image->Resize(width=>170, height=>240);
	$image->Write($f[0].$f[5].$code.'.jpg');
	$image->Write($f[0].$f[6].$code.'.jpg');
	$dba->[$numb][2][0] = 1;
	DumpFile($base.$basenumb, $dba);
	DumpFile($base.8, $dba8);
	DumpFile($base.4, $dba4);
	return $dba
}
__PACKAGE__->meta->make_immutable;

1;
