package kshisa::Model::Data;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use LWP;
use LWP::Simple qw(getstore);
use File::Copy;
#use Log::Any '$log';
#use Log::Any::Adapter ('File', '/home/marat/Kshisa/file.log');
extends 'Catalyst::Model';

=head1 NAME
kshisa::Model::Data - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=encoding utf8
=head1 AUTHOR
Marat Hakimov
=head1 LICENSE
This library is not free software. You cannot redistribute it and/or modify
it under the same terms as Perl itself.
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

sub readds {
    my ($self, $numb, $bnumb, $base) = @_;
	my $dba = LoadFile($base.$bnumb);
    my (%glob, @d);
	my $shem  = $dba->[0];
    push @d, $shem->[$_] for 0..$#{$shem};
    
    for my $x (0..$#{$shem}) {
		my ($a, $b) = ($1, $2) if $d[$x][2] =~ /^(\d+)_(\d+)$/;
        if ($d[$x][1] == 0 or $d[$x][1] == 5) {
            for my $y (0..$a) {
                $glob{$x.'_'.$y.'_0'} = $dba->[$numb][$x][$y];
            }            
        }
        if ($d[$x][1] == 2 or $d[$x][1] == 3) {
            for my $y (0..$a) {
                $glob{$x.'_'.$y.'_0'} = $dba->[$numb][$x][$y][0];
            }            
        }
        if ($d[$x][1] == 4) {
            for my $y (0..$a) {
                for my $z (0..$b) {
                    $glob{$x.'_'.$y.'_'.$z} = $dba->[$numb][$x][$y][$z];
                }
            } 
        }
    }
    return \%glob
}
sub insert {
	my ($self, $base, $param, $bnumb, $home) = @_;
    my ($timea, @d, @t, @f, @n, @time, $flag);
    $bnumb = 11 if $param->{'3_0_0'} > 2009;
    $bnumb = 10 if $param->{'3_0_0'} > 1999 and $param->{'3_0_0'} < 2010;
    $bnumb = 9  if $param->{'3_0_0'} > 1961 and $param->{'3_0_0'} < 2000;
    $bnumb = 8  if $param->{'3_0_0'} > 1919 and $param->{'3_0_0'} < 1962;
    $bnumb = 7  if $param->{'3_0_0'} < 1920;

	my $shem = LoadFile($base.0);
    my $dba  = LoadFile($base.$bnumb);
	my $dba1 = LoadFile($base.'1');	
    push @f, $shem->[4][$_] for 0..$#{$shem->[4]};
	push @n, $shem->[5][$_] for 0..$#{$shem->[5]};
	push @d, $shem->[2][$_] for 0..$#{$shem->[2]};
	my $name = $#{$dba1}+1;
    my $numb = ++$#{$dba};
	my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    
    my $resimdb = LWP::UserAgent->new->get($d[0][4][0].$param->{'0_2_0'}.$d[0][4][7], 'User-Agent' => $UA);
    my ($rols) = _mine($resimdb, $d[0][4][12], $d[0][4][13]);    
    my ($pers) = _mine($resimdb, $d[0][4][12], $d[0][4][14]);

	($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime(); # code
    for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
    my $time = $bnumb.'f'.($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];

	$dba->[$numb][0][0] = $time;
    $dba->[$numb][0][1] = $param->{'0_1_0'};
	$dba->[$numb][0][2] = $param->{'0_2_0'};
	$dba->[$numb][0][3] = $param->{'0_3_0'}*1;
	for my $i (1..$#{$shem->[2]}) {
		my ($a, $b) = ($1, $2) if $d[$i][2] =~ /^(\d+)_(\d+)$/;
    	if ($d[$i][3] == 1) {
		    if ($d[$i][6]) {
                if ($param->{$i.'_0_0'} =~ m{$d[$i][6]}) {
	                $dba->[$numb][$i][0] =  ($1 * $d[$i][7][0] + $d[$i][7][1]) + $2;
                }
	        }
			else {
				for (0..$a) {
				    if ($param->{$i.'_'.$_.'_0'} =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
						$dba->[$numb][$i][$_] = $param->{$i.'_'.$_.'_0'}*1 if $param->{$i.'_'.$_.'_0'}
					}
	    	        else {
						$dba->[$numb][$i][$_] = $param->{$i.'_'.$_.'_0'} if $param->{$i.'_'.$_.'_0'}
					}
			    }
			}				
		}
		if ($d[$i][3] == 2) {
			my $dbaf = LoadFile($base.'2');
			for my $p (0..$a) {
		        if ($param->{$i.'_'.$p.'_0'}) {
                    for (1..$#{$dbaf}) {
                        if ($dbaf->[$_][1][1] eq $param->{$i.'_'.$p.'_0'}) {
							$dba->[$numb][$i][$p][0] = $dbaf->[$_][0][0];
							$dba->[$numb][$i][$p][1] = $dbaf->[$_][0][1];
							$dba->[$numb][$i][$p][2] = $dbaf->[$_][1][0];
							$dba->[$numb][$i][$p][3] = $dbaf->[$_][1][1];
						}
					}
				}
			}
		}
		if ($d[$i][3] == 3) {
			my $dbaf = LoadFile($base.'3');
			for my $p (0..$a) {
		        if ($param->{$i.'_'.$p.'_0'}) {
                    for (1..$#{$dbaf}) {
                        if ($dbaf->[$_][1][1] eq $param->{$i.'_'.$p.'_0'}) {
							$dba->[$numb][$i][$p][0] = $dbaf->[$_][0][0];
							$dba->[$numb][$i][$p][1] = $dbaf->[$_][0][1];
							$dba->[$numb][$i][$p][2] = $dbaf->[$_][1][0];
							$dba->[$numb][$i][$p][3] = $dbaf->[$_][1][1];
						}
					}
				}
			}
		}
		if ($d[$i][3] == 4) { #persons
            for my $p (0..$a) {
				if ( length($param->{$i.'_'.$p.'_2'}) > 0) {
					$flag = 0;
                    for (1..$#{$dba1}) {
                        if ($param->{$i.'_'.$p.'_2'} eq $dba1->[$_][1][1]) {
							$dba->[$numb][$i][$p][0] = $dba1->[$_][0][0];
							$dba->[$numb][$i][$p][1] = $dba1->[$_][1][0];
							$dba->[$numb][$i][$p][2] = $dba1->[$_][1][1];
							$dba1->[$_][0][1] = $param->{$i.'_'.$p.'_0'};
							$flag = 1
						}
					}
					if ($flag == 0) {
						($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
                        for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
                        $timea = ($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	                    $dba->[$numb][$i][$p][0] = '1f'.$timea;
                        $dba->[$numb][$i][$p][1] = $param->{$i.'_'.$p.'_1'};
						$dba->[$numb][$i][$p][2] = $param->{$i.'_'.$p.'_2'};
						$dba1->[$name][0][0] = '1f'.$timea;
						$dba1->[$name][0][1] = $param->{$i.'_'.$p.'_0'};
						$dba1->[$name][0][2] = $param->{$i.'_'.$p.'_3'};
						$dba1->[$name][1][0] = $param->{$i.'_'.$p.'_1'};
						$dba1->[$name][1][1] = $param->{$i.'_'.$p.'_2'};
						$dba1->[$name][2][0] = 0;
                        my $response = LWP::UserAgent->new->get('https://www.imdb.com/name/'.
		                                $param->{$i.'_'.$p.'_3'}, 'User-Agent' => $UA);
						for my $y ($response->decoded_content) {
							while ( $y =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
							    getstore($1, $home.$n[0].$dba1->[$name][0][0].'.jpg');
                                my $image = Image::Magick->new;
                                $image->Read($home.$n[0].$dba1->[$name][0][0].'.jpg'); 
                                $image->Resize(width=>170, height=>240);
                                $image->Write($home.$f[1].$dba1->[$name][0][0].'p2.jpg');
						        $image->Write($home.$n[0].$dba1->[$name][0][0].'p2.jpg');
								$image->Resize(width=>85, height=>120);
								$image->Write($home.$f[1].$dba1->[$name][0][0].'p1.jpg');
						        $image->Write($home.$n[0].$dba1->[$name][0][0].'p1.jpg');
							    $dba1->[$name][2][0] = 1;
						    }
						}
						$name = $name + 1;	
						sleep 1;
                    }
					if ($i == 8) {
                        for my $y (0..@$rols) {
                            if ($dba->[$numb][$i][$p][2] eq $pers->[$y]) {
                                $dba->[$numb][$i][$p][3] = $rols->[$y];
                            }
                        }
					}
				}
			}
		}
	}
	$shem->[1][1][2] = $name - 1;
    $shem->[1][$bnumb][2] = $shem->[1][$bnumb][2] + 1;
    $shem->[1][0][1] = $shem->[1][4][2] + $shem->[1][5][2] + $shem->[1][6][2] + $shem->[1][7][2] +
	                   $shem->[1][8][2] + $shem->[1][9][2] + $shem->[1][10][2] +$shem->[1][11][2];

	my $image = Image::Magick->new; #MAKE POSTER
	$image->Read($home.$n[0].'0.jpg');
    $image->Resize(width=>170, height=>240);
	$image->Write($home.$f[$bnumb].$time.'p2.jpg');
	$image->Write($home.$n[0].$time.'p2.jpg');
	$image->Resize(width=>85, height=>120);
	$image->Write($home.$f[$bnumb].$time.'p1.jpg');
	$image->Write($home.$n[0].$time.'p1.jpg');

    my (@four, @rest);  #MAKE MINI AND SORT IMAGES
	my $x = 1;
	for (1..$dba->[$numb][0][3]) {
		if ($param->{'k'.$_}) {
			my $image = Image::Magick->new;
	        $image->Read($home.$n[0].$_.'.jpg');
			$image->Crop(geometry=>'300x180+10+10');
            $image->Resize(width=>170, height=>100);
			$image->Write($home.$n[0].$time.'m'.$x.'.jpg');
            copy ($home.$n[0].$time.'m'.$x.'.jpg', $home.$f[$bnumb].$time.'m'.$x.'.jpg');
			copy ($home.$n[0].$_.'.jpg', $home.$f[$bnumb].$time.'k'.$x.'.jpg');
			rename ($home.$n[0].$_.'.jpg', $home.$n[0].$time.'k'.$x.'.jpg');
			$x++;
			push @four, $_;
		}
	}
	$flag = 0;
    for my $y (1..$dba->[$numb][0][3]) {
		for my $z (@four) {
            if ($y == $z) {
				$flag = 1
			}
		}
		push @rest, $y if $flag != 1;
		$flag = 0;
	}
	for (@rest) {
        copy ($home.$n[0].$_.'.jpg', $home.$f[$bnumb].$time.'k'.$x.'.jpg');
        rename ($home.$n[0].$_.'.jpg', $home.$n[0].$time.'k'.$x.'.jpg');
		$x++
	}
	my @film = @$dba;

    @film = sort {                                                      # SORT BY YEAR AND REIT
        $a->[3][0] cmp $b->[3][0]
        ||
        $b->[2][0] cmp $a->[2][0]
    } @film;
	for (0..$#film) {
		if ($film[$_][0][0] eq $time) {
			$numb = $_;
		}
	}
    $dba = [@film];
	DumpFile($base.'0', $shem);
    DumpFile($base.'1', $dba1);
	DumpFile($base.$bnumb, $dba);

	return $numb, $bnumb
}
sub update {
    my ($self, $base, $bnumb, $numb, $h, $w, $d, $n, $newl, $home) = @_;
	my (@f, @n, $line, $imdb, $eng, $r);
	my $dba = LoadFile($base.$bnumb);	
	my $shem = LoadFile($base.0);
    push @f, $shem->[4][$_] for 0..$#{$shem->[4]};
	push @n, $shem->[5][$_] for 0..$#{$shem->[5]};
	if ($bnumb == 1 && $h == 1) {  # UPDATE PERSONS
	    my @files = (4..9);
	    for my $n (@files) {
            my $file = LoadFile($base.$n);
            for my $x (1..$#{$file}) {
                for my $y (7..12) {
                    for my $z (0..$file->[0][$y][2]) {
                        if ($file->[$x][$y][$z][0] eq $dba->[$numb][0][0]) {
                            $file->[$x][$y][$z][$h+1] = $newl;
                        }
                    }
                }  
            } 
	        DumpFile($base.$n, $file);
        }
    }
	if ($n == 0) {
		if ($newl =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
			$newl = $newl * 1;
			$dba->[$numb][$h][$w] = $newl;
		}
		else {
			$dba->[$numb][$h][$w] = $newl;
		}
    }
	elsif ($h == 5 or $h == 6) {
        my $dba0 = LoadFile($base.($h-3));
	    for my $x (1..$#{$dba0}) {
			if ($newl eq $dba0->[$x][0][1]) {
		     	$dba->[$numb][$h][$w][0] = $dba0->[$x][0][0];
				$dba->[$numb][$h][$w][1] = $dba0->[$x][0][1];
				$dba->[$numb][$h][$w][2] = $dba0->[$x][1][0];
				$dba->[$numb][$h][$w][3] = $dba0->[$x][1][1];
			}
		}
	}
	elsif ($n == 1) {
		if ($d == 0 && $bnumb != 1) {
		    if ($newl =~ /^nm\d+/) {
			    my $dba1 = LoadFile($base.$n);
		        my $numb1 = $#{$dba1} + 1;
		        my $flag = 0;
		        for my $x (1..$#{$dba1}) {
                    if ($newl eq $dba1->[$x][0][2]) {
				        $dba->[$numb][$h][$w][0] = $dba1->[$x][0][0];
				        $dba->[$numb][$h][$w][1] = $dba1->[$x][1][0];
				        $dba->[$numb][$h][$w][2] = $dba1->[$x][1][1];
     			        $flag = 1;
		    	    }
		        }
		        if ($flag == 0) {
			        my @time;
			        my $foto = 0;
			        ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
                    for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
                    my $timea = ($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	                $dba->[$numb][$h][$w][0] = '1f'.$timea;
                    $dba1->[$numb1][0][0]    = '1f'.$timea;
				    $dba1->[$numb1][2][0] = 0;
     		        my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
                    $imdb = LWP::UserAgent->new->get('https://www.imdb.com/name/'.$newl, 'User-Agent' => $UA);
                    for ($imdb->decoded_content) {
                        while ( $_ =~ m{class="itemprop">(.*?)</span>}mg ) { 
                            $eng = $1;
			            }
				        while ( $_ =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
					        getstore($1, $home.$f[0].'1f'.$timea.'p1.jpg');
						    getstore($1, $home.$f[6].'1f'.$timea.'p1.jpg');
                            $dba1->[$numb1][2][0] = 1;
				        }
		            }
			        $dba->[$numb][$h][$w][2] = $eng;
				    $dba1->[$numb1][1][1] = $eng;
				    $dba1->[$numb1][0][2] = $newl;
    	        }
		        DumpFile($base.1, $dba1);
		    }
			else {
			    $dba->[$numb][$h][$w] = [];
                DumpFile($base.$bnumb, $dba);
			}
		}
		elsif ($bnumb == 1) {
			if ($newl =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
			    $newl = $newl * 1;
			    $dba->[$numb][$h][$w] = $newl;
		    }
		    else {
			    $dba->[$numb][$h][$w] = $newl;
		    }			    
		}
		else {
			$dba->[$numb][$h][$w][$d] = $newl;
		}
	}	
	DumpFile($base.$bnumb, $dba);
	return $dba
}
sub delete {
    my ($self, $base, $bnumb, $numb, $home) = @_;
	my @f;
    my $dba = LoadFile($base. $bnumb);
	my $shem = LoadFile($base.0);
	push @f, $shem->[4][$_] for 0..6;
    unlink $home.$f[6].$dba->[$numb][0][0].'p2.jpg';
    unlink $home.$f[5].$dba->[$numb][0][0].'p2.jpg';
    for (1..$dba->[$numb][0][3]) {
        unlink $home.$f[6].$dba->[$numb][0][0].'k'.$_.'.jpg';
        unlink $home.$f[5].$dba->[$numb][0][0].'k'.$_.'.jpg';
    }
    for (1..4) {
        unlink $home.$f[6].$dba->[$numb][0][0].'m'.$_.'.jpg';
        unlink $home.$f[5].$dba->[$numb][0][0].'m'.$_.'.jpg';
    }
    my @film = @$dba;
    splice @film, $numb, 1;
    my $dba0 = [@film];
    DumpFile($base.$bnumb, $dba0);
	return $dba0
}
sub delpics {
    my ($self, $base, $bnumb, $numb, $param, $home) = @_;
	my $dba = LoadFile($base. $bnumb);
	my $pics = $dba->[$numb][0][3];
	my $shem = LoadFile($base.0);
	my @f;
	push @f, $shem->[4][$_] for 0..6;
	for my $x (1..$dba->[$numb][0][3]) {
        if ($param->{'kad'.$x}) {
			unlink $home.$f[6].$dba->[$numb][0][0].'k'.$x.'.jpg';
			$pics = $pics - 1;
		}
	}
	my $z = 1;
	for my $y (1..$dba->[$numb][0][3]) {
		if (-e $home.$f[6].$dba->[$numb][0][0].'k'.$y.'.jpg'){
		    rename $home.$f[6].$dba->[$numb][0][0].'k'.$y.'.jpg', 
		           $home.$f[6].$dba->[$numb][0][0].'k'.$z.'.jpg';
		    $z++;			
		}
	}
	$dba->[$numb][0][3] = $pics;
	DumpFile($base.$bnumb, $dba);
	return $dba
}
sub send {
	my ($self, $base, $bnumb, $numb, $home, $file) = @_;
	my $snip = LoadFile($base.0);
	my (@f);
	push @f, $snip->[4][$_]  for 0..$#{$snip->[4]};	
    my $dbaa = LoadFile($base.$bnumb);
	my $dbab = LoadFile($base.$file);
	my $tape = LoadFile($base.'/c/5');
    my $code = $dbaa->[$numb][0][0];
    my $newc = $file.$1 if $code =~ /\d+(f\d+)/;
	my $total = $#{$dbab} + 1;
    my $totap = $#{$tape} + 1;
	$tape->[$totap][0] = $newc;
	$tape->[$totap][1] = $dbaa->[$numb][3][0];
	$tape->[$totap][2] = $dbaa->[$numb][2][0];

	move $home.$f[$bnumb].$code.'p2'.$_.'.jpg', $home.$f[$file].$newc.'p2'.$_.'.jpg';
    for (1..4) {
      move $home.$f[$bnumb].$code.'m'.$_.'.jpg', $home.$f[$file].$newc.'m'.$_.'.jpg'
	}
	for (1..$dbaa->[$numb][0][3]) {
	  move $home.$f[$bnumb].$code.'k'.$_.'.jpg', $home.$f[$file].$newc.'k'.$_.'.jpg'
	}
	$dbab->[$total] = $dbaa->[$numb];
    $dbab->[$total][0][0] = $newc;
	
	my @film = @$dbaa;
    splice @film, $numb, 1;
    $dbaa = [@film];
	$snip->[1][$bnumb][2] = $snip->[1][$bnumb][2] - 1;
    $snip->[1][$file][2] = $snip->[1][$file][2] + 1;
    
	DumpFile($base.0, $snip);
    DumpFile($base.$bnumb, $dbaa);
    DumpFile($base.$file, $dbab);

    DumpFile($base.'/c/5', $tape);

	return $file, $total
}
sub imgs {
	my ($self, $base, $bnumb, $numb, $home, $pics) = @_;
    my $dba = LoadFile($base.$bnumb);
	my $shem = LoadFile($base.0);
	my (@f, @n);
    push @f, $shem->[4][$_] for 0..$#{$shem->[4]};
	push @n, $shem->[5][$_] for 0..$#{$shem->[5]};
    for (1..$pics) {
        my $image = Image::Magick->new;
        $image->Read($home.$n[0].$_.'.jpg');
        $image->Set(Gravity => 'Center');
        $image->Resize(geometry => '350x240');
        $image->Write($home.$f[$bnumb].$dba->[$numb][0][0].'k'.($_ + $dba->[$numb][0][3]).'.jpg');
		$image->Write($home.$n[0].$dba->[$numb][0][0].'k'.($_ + $dba->[$numb][0][3]).'.jpg');
	}
	$dba->[$numb][0][3] = $pics + $dba->[$numb][0][3];
	DumpFile($base.$bnumb, $dba);		
}
sub resize {
	my ($self, $base, $bnumb, $numb, $home) = @_;
	my $dba = LoadFile($base.$bnumb);
	my $shem = LoadFile($base.0);
	my (@f, @n);
    push @f, $shem->[4][$_] for 0..$#{$shem->[4]};
	push @n, $shem->[5][$_] for 0..$#{$shem->[5]};
	
	for (0..0) {
      my $image = Image::Magick->new;
      $image->Read($home.$f[$bnumb].$dba->[$numb + $_][0][0].'p2.jpg');
      $image->Set(Gravity => 'Center');
      $image->Resize(geometry => '85x120');
      $image->Write($home.$f[$bnumb].$dba->[$numb + $_][0][0].'p1.jpg');

	  #rename ($home.$f[$bnumb].$dba->[$numb + $_][0][0].'.jpg', 
	  #        $home.$f[$bnumb].$dba->[$numb + $_][0][0].'p2.jpg');	  
	}
}
sub tape {
	my ($self, $base, $bnumb, $numb, $home, $file) = @_;
	my $dba  = LoadFile($base.$bnumb);
	my $code = $dba->[$numb][0][0];
	my $tape = LoadFile($base.'/c/'.$file);
	my $totap = $#{$tape} + 1;
	$tape->[$totap][0] = $code;
	$tape->[$totap][1] = $dba->[$numb][3][0];
	$tape->[$totap][2] = $dba->[$numb][2][0];
	my @film = @$tape;
    @film = sort {                                                      # SORT BY YEAR AND REIT
        $a->[1] cmp $b->[1]
        ||
        $b->[2] cmp $a->[2]
    } @film;
	$tape = [@film];
	DumpFile($base.'c/'.$file, $tape);
	return $bnumb, $numb
}
sub logs {
    my $pass;
    my @chars = split( " ","A B C D E F G H" );
    foreach my $line (1..6) {
		$pass .= '<p>';
        foreach my $char (@chars) {
            $pass = $pass.'<label><input type="radio" name="P'.$line.'"value="'.$char.'" />'.$char.'</label>' if $line != 6;
            $pass = $pass.'<label><input type="radio" name="P'.$line.'" onclick="subm1()" value="'.$char.'" />'.$char.'</label>' if $line == 6;
        }
    }
    my $text = '<div class="center_col">
                <div id="user">
                <div id="mess">Enter your password<p></div>
                <div id="dash"><hr><hr>'.$pass.'<hr></div>
                </div></div>';
    return $text
}

__PACKAGE__->meta->make_immutable;

1;
