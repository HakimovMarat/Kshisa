package kshisa::Model::DSet;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use File::Copy;
use Image::Magick;
use LWP;
use LWP::Simple qw(getstore);

extends 'Catalyst::Model';

=head1 NAME
kshisa::Model::DSet - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=cut
my $s0 = '<img class="';                                                # SNIPETS
my $s1 = '"><input class="';
my $s2 = '" type="image" name="';
my $s3 = '" src="/images/mini/';
my $s4 = '.jpg" /></a>';
my $s5 = '<div class="numb">';
my $s6 = '</div>';
my $s7 = '" src="/images/butt/';
my $s8 = '<a title="';
my $s9 = '.png" /></a>';
my $s10 = '" src="/images/find0/';

sub readds {
    my ($self, $base, $numb, $foto, $basenumb, $find0, $numbl) = @_;
    my ($forml, $formr, @d, @s, @o, @t, @b, @i, @men, @name, $crew, @code);
    my $dba0  = LoadFile($base. $basenumb);
    my $genr  = LoadFile($base.'genr');
	my $coun  = LoadFile($base.'coun');
	my $snip  = LoadFile($base.'snip');
	my $shem  = LoadFile($base.'shem');
    my $dba0size = $#{$dba0->[$numb]};
    my $shemsize = $#{$shem->[0]};
	my %files = ('genr' => $genr,
	             'coun' => $coun,
                );
    push @d, $shem->[0][$_]    for 0..$shemsize;
    push @s, $snip->[0][0][$_] for 0..7;
    push @o, $snip->[0][1][$_] for 0..11;
    push @t, $snip->[0][2][$_] for 0..9;
	push @i, $snip->[0][3][$_] for 0..8;
    push @b, $dba0->[$numb];

    for (0..$shemsize) {
        my $x = 0;
        my $name = $dba0->[0][$_][4];
        if ($d[$_][1] == 1) {
            for my $y (0..$d[$_][2]-1) {
                if ($d[$_][3] == 2) {    
 		            $forml = $forml.$s[0].$s[1].'b'.$name.($x=++$x).'l1'.$s[2].$name.
				                          $s[3].$name.$x.'l1'.$s[4].$s[5].$s[6]; 
 		            $formr = $formr.$s[0].$s[1].'b'.$name.$x.'r1'.$s[2].$name.
				                          $s[3].$name.$x.'r1'.$s[4].$b[0][$_][$y].$s[5].$s[6];
                }
                if ($d[$_][3] == 1) {
				    if ($b[0][$_][$y][0]) {
                        $forml = $forml.$s[0].$s[1].'b'.$name.($x=++$x).'l'.$y.$s[2].($y+1).$name.$x.
		 		                          $s[3].$name.$x.'l'.$y.$s[4].$s[5].$s[6];
		                $formr = $formr.$s[0].$s[1].'b'.$name.$x.'r'.$y.$s[2].($y+1).$name.$x.
				                          $s[3].$name.$x.'r'.$y.$s[4].$b[0][$_][$y][1].$s[5].$s[6];							  
		     		    $forml = $forml.$s[0].$s[1].'b'.$name.($x=++$x).'l'.($y+1).$s[2].($y+1).$name.$x.
				                          $s[3].$name.$x.'l'.$y.$s[4].$s[5].$s[6];
			    	    $formr = $formr.$s[0].$s[1].'b'.$name.$x.'r'.($y+1).$s[2].($y+1).$name.$x.
				                          $s[3].$name.$x.'r'.$y.$s[4].$b[0][$_][$y][2].$s[5].$s[6];
					    push @men,  $b[0][$_][$y][3] if $b[0][$_][$y][3];
					    push @name, $name.'<br />'.$b[0][$_][$y][1].'<br />'.$b[0][$_][$y][2] if $b[0][$_][$y][2];                             
                    	push @code, $b[0][$_][$y][0] if $b[0][$_][$y][0];				
					}
					else {
                        $forml = $forml.$s[0].$s[1].'b'.$name.($x=++$x).'l'.($y+1).$s[2].($y+1).$name.$x.
		 		                          $s[3].$name.$x.'l'.($y+1).$s[4].$s[5].$s[6];
		                $formr = $formr.$s[0].$s[1].'b'.$name.$x.'r'.($y+1).$s[2].($y+1).$name.$x.
				                          $s[3].$name.$x.'r'.($y+1).$s[4].$s[5].$s[6];						
					}
					$x = 0;
				} 
            }
        }
        if ($d[$_][1] == 2) {
            for my $y (0..$d[$_][2]-1) {
                if ($d[$_][3] == 3) { 
					my $rows = $files{$name};   
			        $forml = $forml.$o[0].$o[1].'b'.$name.($x=++$x).'l'.$o[2].$name.
					                $o[3].$name.$x.'l1'.$o[4];
			        for my $list (0..$#{$rows->[0]}) {
				        $forml = $forml.$o[5].$rows->[0][$list][2];
					    $forml = $forml.$o[6].$rows->[0][$list][2].$o[7];
                    }    
			        $forml = $forml.$o[8].$o[9].$o[10];

			        $formr = $formr.$o[0].$o[1].'b'.$name.$x.'r'.$o[2].$name.
					                $o[3].$name.$x.'r1'.$o[4];
			        for my $list (0..$#{$rows->[0]}) {
				        $formr = $formr.$o[5].$rows->[0][$list][2];
     			        $formr = $formr.$o[11] if $rows->[0][$list][0] eq $b[0][$_][$y][1];
					    $formr = $formr.$o[6].$rows->[0][$list][2].$o[7];
			        } 
			        $formr = $formr.$o[8].$o[9].$o[10];
                } 
            }
        }
        if ($d[$_][1] == 3) {
            for my $y (0..$d[$_][2]-1) {
                if ($d[$_][3] == 2) { 
		            $forml = $forml.$t[0].$t[1].$t[2].'b'.$name.($x=++$x).'l1'.$t[3].$name.$t[4].$t[8].$t[9].
					                $t[0].$t[1].$t[5].$name.$x.'l1'.$t[6].$t[7].$t[8].$t[9];    
		            $formr = $formr.$t[0].$t[1].$t[2].'b'.$name.$x.'r1'.$t[3].$name.$t[4].$t[8].$t[9].
					                $t[0].$t[1].$t[5].$name.$x.'r1'.$t[6].$b[0][$_][0].$t[7].$t[8].$t[9]; 
                }    
            }
        }
    }
	$crew = '<div id="rows">';
	for (0..$#men) {
        $crew = $crew.$i[0].$i[1].$i[2].$code[$_].$i[3].$foto.$men[$_].$i[4].$i[5].$name[$_].$i[6].$i[7];
	}
	$crew = $crew.'</div>';
	my $panl = '<input type="hidden" name="idr" value="'.$numb.'" />
                <input type="hidden" name="idl" value="'.$numbl.'" />
	            <div id="panl">
				    <input type="text"  name="file"   class="address" value="'.$basenumb.'" size="1">
                    <input type="text"  name="numb"   class="address" value="'.$numb.'" size="1">
                    <input type="image" name="count"  class="search" src="/images/butt/search.png">
                    <input type="text"  name="Address" class="address" size="35">
 			        <img class="search" src="/images/butt/imdb.png">
			        <input type="text"  name="imdb"   class="address" />
                    <input type="image" name="search" class="search" src="/images/butt/search.png">
                </div>'; 

	opendir (my $dh0, $find0);
	my @files = grep { !/^\./ } readdir($dh0);
	$_ =~ s/.jpg// for (@files);

	my ($leftp, $rigtp);
	$leftp =  '<hr><input type="image" name="prevl" src="/images/bill/lt.png">
                   <input type="image" name="nextl" src="/images/bill/rt.png"><hr>';
    $rigtp =  '<hr><input type="image" name="prevr" src="/images/bill/lt.png">
                   <input type="image" name="nextr" src="/images/bill/rt.png"><hr>';
	for ($numbl..$numbl+6) {
        $leftp = $leftp.$s5.($_+1).$s6.$s8.$files[$_].$s1.'image'.$s2.($_+1).$s10.$files[$_].'.jpg" /></a>'
	}
    $leftp = $leftp.$s5.$s6; 
    for (0..5) {
		$rigtp = $rigtp.$s5.($numb-$_).$s6.$s8.$dba0->[$numb-$_][1][1].$s1.'image'.$s2.($numb-$_).$s3.$dba0->[$numb-$_][0][0].'m0.jpg" /></a>' 
		         if $dba0->[$numb-$_][0][0]
	}

    return $forml, $formr, $crew, $panl, $rigtp, $leftp
}

sub addone {
	my ($self, $base, $param, $imgm, $imgk, $imgs2, $imgs3, $findp, $crewp, $Base, $imgs4, $basenumb, $find3) = @_;
 
    my ($numb, $time, $timea, @d, @s, @o, @t, @i, @time);
    my $dba0 = LoadFile($base. $basenumb);
	my $dba1 = LoadFile($base.'1');	
    my $dba2 = LoadFile($base.'2');
    my $dba3 = LoadFile($base.'3');

	my $shem  = LoadFile($base.'shem');
    my $dba0size = $#{$dba0};
    my $shemsize = $#{$shem->[0]};
	my $name = $#{$dba1};
	my %files = ('genr' => $dba3,
	             'coun' => $dba2,
                );
    push @d, $shem->[0][$_]    for 0..$shemsize;
    $numb = ++$dba0size;
	($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
    for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
    $time = $basenumb.'f'.($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	$dba0->[$numb][0][0] = $time;
	$dba0->[$numb][0][1] = $param->{$d[0][0].'1l'};
	my $imdb = $param->{$d[0][0].'2l'};
	$dba0->[$numb][0][2] = $imdb;
	$dba0->[$numb][0][3] = $param->{$d[0][0].'3l'}*1;
	for my $i (1..$shemsize) {
        if ($d[$i][6]) {
            if ($param->{$d[$i][0].'1l'} =~ m{$d[$i][6]}) {
	            $dba0->[$numb][$i][0] =  ($1 * $d[$i][7][0] + $d[$i][7][1]) + $2;
            }
		}	
		else {
			if ($d[$i][1] == 1) {
				if ($d[$i][3] == 1) {
                    for my $p (1..$d[$i][2]) {
					    if ($param->{$d[$i][0].$p.'l2'}) {
						    my $flag = 0;
                            for (1..$#{$dba1}) {
                                if ($param->{$d[$i][0].$p.'l2'} eq $dba1->[$_][2]) {
								    $dba0->[$numb][$i][$p-1][0] = $dba1->[$_][0];
								    $dba0->[$numb][$i][$p-1][1] = $dba1->[$_][1];
								    $dba0->[$numb][$i][$p-1][2] = $dba1->[$_][2];
								    if ($dba1->[$_][4] == 1) {
									   $dba0->[$numb][$i][$p-1][3] = $dba1->[$_][0];
								    }
								    elsif ($dba1->[$_][3] == 0) {
									    $dba0->[$numb][$i][$p-1][3] = 'blank';
								    } 
								    $flag = 1
							    }
							}
							if ($flag == 0) {
								($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
                                for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
                                $timea = ($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	                            $dba0->[$numb][$i][$p-1][0] = '1f'.$timea;
                                $dba0->[$numb][$i][$p-1][1] = $param->{$d[$i][0].$p.'l1'};
								$dba0->[$numb][$i][$p-1][2] = $param->{$d[$i][0].$p.'l2'};
								$dba0->[$numb][$i][$p-1][3] = 'blank';
							    $dba1->[$name][0] = '1f'.$timea;
								$dba1->[$name][1] = $param->{$d[$i][0].$p.'l1'};
								$dba1->[$name][2] = $param->{$d[$i][0].$p.'l2'};
								$dba1->[$name][3] = $param->{$d[$i][0].$p.'l3'};
								$dba1->[$name][4] = 0;
								my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
                                my $response = LWP::UserAgent->new->get('https://www.imdb.com/name/'.
		                                               $param->{$d[$i][0].$p.'l3'}, 'User-Agent' => $UA);
								for my $y ($response->decoded_content) {
									while ( $y =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
										getstore($1, $crewp.'1f'.$timea.'.jpg');
                                        copy ($crewp.'1f'.$timea.'.jpg', $imgs4.'1f'.$timea.'.jpg');
                                        $dba1->[$name][4] = 1;
										$dba0->[$numb][$i][$p-1][3] = '1f'.$timea;
									}
								}
								$name = $name + 1;
								sleep 1;

                            }
					    }
				    }
				}
				if ($d[$i][3] == 2) {
					for (1..$d[$i][2]) {
						if ($param->{$d[$i][0].$_.'l'}) {
							my $field = $param->{$d[$i][0].$_.'l'};
							if ($field =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
								$field = $field*1
							}
						    $dba0->[$numb][$i][$_-1] = $field;						
						}
					}
				}
			}
			if ($d[$i][1] == 2) {
				my $dba = $files{$d[$i][0]};
				for my $p (1..$d[$i][2]) {
			        if ($param->{$d[$i][0].$p.'l'}) {
                        for (0..$#{$dba->[0]}) {
                            if ($dba->[0][$_][3] eq $param->{$d[$i][0].$p.'l'}) {
								$dba0->[$numb][$i][$p-1] = $dba->[0][$_];
							}
						}
					}
				}
			}
			if ($d[$i][1] == 3) {
				for (1..$d[$i][2]) {
					if ($param->{$d[$i][0].$_.'l'}) {
					    $dba0->[$numb][$i][$_-1] = $param->{$d[$i][0].$_.'l'}						
					}
				}				
			} 
		}
	}
	$dba1->[$name][0] = $name;
    copy ($findp.'1.jpg', $imgs2.$time.'p1.jpg');
	copy ($findp.'1.jpg', $imgk.$time.'p1.jpg');

	my $image = Image::Magick->new;
	$image->Read($findp.'1.jpg');
    $image->Resize(width=>260, height=>368);
    $image->Write($imgs3.$time.'m0.jpg');
	$image->Write($imgm.$time.'m0.jpg');
    my @four;
	my $x = 1;
	for (1..$param->{'code3l'}+1) {
		if ($param->{'m'.$_}) {
			my $image = Image::Magick->new;
	        $image->Read($findp.$_.'.jpg');
            $image->Resize(width=>255, height=>150);
            $image->Write($imgs3.$time.'m'.$x.'.jpg');
			$image->Write($imgm.$time.'m'.$x.'.jpg');
			copy ($findp.$_.'.jpg', $imgk.$time.'k'.$x.'.jpg');
			copy ($findp.$_.'.jpg', $imgs2.$time.'k'.$x.'.jpg');
			++$x;
			push @four, $_;
		}
	}
	my (@all, @rest);
	my $flag = 0;
	for (1..$param->{'code3l'}+1) {
		if ($param->{'k'.$_}) {
			push @all, $_;
		}
	}
    for my $y (@all) {
		for my $z (@four) {
             if ($y == $z) {
				 $flag = 1;
			 }
		}
        if ($flag == 0) {
			push @rest, $y;
		}
		$flag = 0;
	}
	for (@rest) {
		copy ($findp.$_.'.jpg', $imgs2.$time.'k'.$x.'.jpg');
		copy ($findp.$_.'.jpg', $imgk.$time.'k'.$x.'.jpg');
		$x++;
	}
	my @film = @$dba0;
    @film = sort {                                                      # SORT BY YEAR AND REIT
        $a->[3][0] <=> $b->[3][0]
        ||
        $b->[2][0] <=> $a->[2][0]
    } @film;
	for (0..$#film) {
		if ($film[$_][0][0] eq $time) {
			$numb = $_;
		}
	}
    $dba0 = [@film];
    DumpFile($base.'1', $dba1);
	DumpFile($Base.'1', $dba1);
	DumpFile($base.$basenumb, $dba0);
	#DumpFile($Base.$basenumb, $dba0);
    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    my $response = LWP::UserAgent->new->get(
       'https://www.imdb.com/title/'.$imdb.'/?ref_=fn_al_tt_1', 'User-Agent' => $UA);
        for ($response->decoded_content) {
            while ( $_ =~ m{<div class="poster">\n?<a href="(.*?)\?ref}mg) {
                my $p = $1;
                my $res = LWP::UserAgent->new->get('https://www.imdb.com'.$p, 'User-Agent' => $UA);
                for ($res->decoded_content) {
                    while ( $_ =~ m{<meta itemprop="image" content="(.*?)"/>}mg) {
                        getstore($1, $find3.$time.'p2.jpg')
                    }
                }
            }
        }
	
	return $numb
}
sub newmini {
    my ($self, $numb, $param, $imgm, $imgk, $findpics, $base, $basenumb, $checkk, $find1, $geometry) = @_;
	my $dba = LoadFile($base.$basenumb);
    my $code = $dba->[$numb][0][0];
	my $max = $dba->[$numb][2][0];
	my $checkm;
	for (1..4) {
		$checkm = $_ if $param->{'m'.$_};
	}
    unlink glob "$findpics*.*";
	my $image = Image::Magick->new;
	$image->Read($imgk.$code.'k'.$checkk.'.jpg');
	$image->Crop(geometry=>$geometry);
    $image->Resize(width=>255, height=>150);
    $image->Write($findpics.$code.'m'.$checkm.'.jpg');
	for (0..4) {
        copy ($imgm.$code.'m'.$_.'.jpg', $findpics.$code.'m'.$_.'.jpg') if ($_ != $checkm);
	}
    copy ($imgk.$code.'k'.$checkk.'.jpg', $findpics.$code.'k'.$checkm.'.jpg');
	copy ($imgk.$code.'k'.$checkm.'.jpg', $findpics.$code.'k'.$checkk.'.jpg');
	for (1..$max) {
        copy ($imgk.$code.'k'.$_.'.jpg', $findpics.$code.'k'.$_.'.jpg') if ($_ != $checkm and $_ != $checkk);
	}
	my $foto = $find1.$code;
	my $p = '<img id="post" name="post"  src="'.$foto.'m0.jpg"/>';
	my $k = '<span><img class="kadr" name="kadr0" src="'.$foto.'m1.jpg"/>
             1<input  type="checkbox" name="m1"></span>
             <span><img class="kadr" name="kadr1" src="'.$foto.'m2.jpg"/>
         	 2<input  type="checkbox" name="m2"></span>
             <span><img class="kadr" name="kadr2" src="'.$foto.'m3.jpg"/>
         	 3<input  type="checkbox" name="m3"></span>
             <span><img class="kadr" name="kadr3" src="'.$foto.'m4.jpg"/>
         	 4<input  type="checkbox" name="m4"></span>
			 <input type="image" name="change" src="/images/butt/dn3.png">';

    my $pics = '<div id="imgs">'.$p.'<div id="foto">'.$k.'<hr></div>'
			  .'<h3>'.$dba->[$numb][1][0].'</h3>'
			  .'<h3>'.$dba->[$numb][1][1].'</h3>'
			  .'<h3>'.$dba->[$numb][3][0].'</h3>
              <input type="image" name="prevr" src="/images/bill/lt.png">
              <input type="image" name="nextr" src="/images/bill/rt.png">
			  <hr><h3>'.$numb.'/'.$#{$dba}.'</h3></div>';
    my $rows;
	$rows = '<div id="rows"><hr>'.$rows.$max;
    for (1..$max) {
        $rows = $rows.'<input type="image" class="image" name="k'.$_.'" src="'.$foto.'k'.$_.'.jpg"/>';
    }
    $rows = $rows.'</div><hr>';
    return $pics, $rows
}
sub change {
	my ($self, $numb, $imgm, $imgk, $findpics, $base, $basenumb, $imgs2, $imgs3) = @_;
	my $dba = LoadFile($base.$basenumb);
	my $code = $dba->[$numb][0][0];
	my $max = $dba->[$numb][2][0];
	for (0..4) {
        copy ($findpics.$code.'m'.$_.'.jpg', $imgm.$code.'m'.$_.'.jpg');
		copy ($findpics.$code.'m'.$_.'.jpg', $imgs3.$code.'m'.$_.'.jpg');
	}
    for (1..$max) {
        copy ($findpics.$code.'k'.$_.'.jpg', $imgk.$code.'k'.$_.'.jpg');
		copy ($findpics.$code.'k'.$_.'.jpg', $imgs2.$code.'k'.$_.'.jpg');
	}
	return $numb
}
sub correct {
    my ($self, $base, $basenumb, $numb, $name, $fild, $newl, $crewp, $imgs4, $Base, $rusname) = @_;
	my $dba = LoadFile($base.$basenumb);
	my $line;
	my $imdb;
	my $eng;
	for (0..$#{$dba->[0]}) {
		if ($name eq $dba->[0][$_][4]) {
			$line = $_;
		}
	}
	my $basenumb0 = $dba->[0][$line][1];
	my $dba0 = LoadFile($base.$basenumb0);
	my $flag = 0;
	if ($basenumb0 == 0) {
		if ($newl =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
			$newl = $newl * 1;
			$dba->[$numb][$line][$fild-1] = $newl;
		}
		else {
			$dba->[$numb][$line][$fild-1] = $newl;
		}
    }
	elsif ($basenumb0 == 2 or $basenumb0 == 3) {
		for my $x (0..$#{$dba0->[0]}) {
			if ($newl eq $dba0->[0][$x][3]) {
				$dba->[$numb][$line][$fild-1] = $dba0->[0][$x];
			}
		}
	}
	
	elsif ($basenumb0 == 1) {
		my $numb0 = $#{$dba0};
		if ($rusname == 0) {
		    my ($code, $rus, $blank);
		    for my $x (1..$#{$dba0}) {
                if ($newl eq $dba0->[$x][3]) {
                $code = $dba0->[$x][0];
				$rus  = $dba0->[$x][1];
				$eng  = $dba0->[$x][2];
				if ($dba0->[$x][2] == 0) {
					$blank = 'blank'
				}
				elsif ($dba0->[$x][2] == 1) {
					$blank = $dba0->[0][$x][0]
				}
				$dba->[$numb][$line][$fild-1][0] = $code;
				$dba->[$numb][$line][$fild-1][1] = $rus;
				$dba->[$numb][$line][$fild-1][2] = $eng;
				$dba->[$numb][$line][$fild-1][3] = $blank;
				$flag = 1;
		    	}
		    }
		    if ($flag == 0) {
			    my @time;
			    my $foto = 0;
			    ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
                for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
                my $timea = ($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	            $dba->[$numb][$line][$fild-1][0] = '1f'.$timea;
                $dba0->[$numb0][0] = '1f'.$timea;
     		    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
                $imdb = LWP::UserAgent->new->get('https://www.imdb.com/name/'.$newl, 'User-Agent' => $UA);
               for ($imdb->decoded_content) {
                    while ( $_ =~ m{<h1 class="header"> <span class="itemprop">(.*?)</span>}mg ) { 
                        $eng = $1;
			        }
				while ( $_ =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
					getstore($1, $crewp.'1f'.$timea.'.jpg');
                    copy ($crewp.'1f'.$timea.'.jpg', $imgs4.'1f'.$timea.'.jpg');
					$dba->[$numb][$line][$fild-1][3] = '1f'.$timea;
                    $dba0->[$name][4] = 1;
					$foto = 1;
				}
		        }
			    $dba->[$numb][$line][$fild-1][2] = $eng;
			    if ($foto == 1) {
				    $dba->[$numb][$line][$fild-1][3] = '1f'.$timea;
			    }
			    elsif ($foto == 0) {
				    $dba->[$numb][$line][$fild-1][3] = 'blank';
			    }
			    $dba0->[$numb0][2] = $eng;
			    $dba0->[$numb0][3] = $newl;
			    $dba0->[$numb0][4] = $foto;
			    $dba0->[$numb0+1][0] = $numb0+1;
			
    	    }			
		}
        elsif ($rusname == 1) {
            $dba0->[$numb0-1][1] = $newl;
			$dba->[$numb][$line][$fild][1] = $newl;
			
		}
	}
	DumpFile($base.$basenumb0, $dba0);
    DumpFile($base.$basenumb, $dba);
	return $rusname
}
sub poster {
    my ($self, $code, $find3, $kads, $mini, $imgs2, $imgs3) = @_;
	my $image = Image::Magick->new;
	$image->Read($find3.$code.'p2.jpg');
    $image->Resize(width=>260, height=>368);
    $image->Write($imgs3.$code.'m0.jpg');
	$image->Write($mini.$code.'m0.jpg');

	move ($kads.$code.'p1.jpg', $find3.$code.'p1.jpg');
    move ($find3.$code.'p2.jpg', $kads.$code.'p1.jpg');
	rename ($find3.$code.'p1.jpg', $find3.$code.'p2.jpg');
 
}

=encoding utf8
=head1 AUTHOR
Marat Haa Kim
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut

__PACKAGE__->meta->make_immutable;

1;
