package kshisa::Model::Data;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use LWP;
use LWP::Simple qw(getstore);
use File::Copy;
extends 'Catalyst::Model';

=head1 NAME
kshisa::Model::Data - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=encoding utf8
=head1 AUTHOR
Marat Haa Kim
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut

sub readds {
    my ($self, $numb, $dba) = @_;
    my (%glob);

    for my $x (0..$#{$dba->[0]}) {
        if ($dba->[0][$x][6] == 0 or $dba->[0][$x][6] == 3) {
            for my $y (0..$dba->[0][$x][2]-1) {
                $glob{$x.'_'.$y.'_0'} = $dba->[$numb][$x][$y];
            }            
        }
        if ($dba->[0][$x][6] == 2) {
            for my $y (0..$dba->[0][$x][2]-1) {
                for my $z (1..2) {
                    $glob{$x.'_'.$y.'_'.$z} = $dba->[$numb][$x][$y][$z];
                }
            }            
        }
        if ($dba->[0][$x][6] == 1) {
            for my $y (0..$dba->[0][$x][2]-1) {
                for my $z (0..4) {
                    $glob{$x.'_'.$y.'_'.$z} = $dba->[$numb][$x][$y][$z];
                }
            } 
        }
    }
    return \%glob
}
sub insert {
	my ($self, $base, $param, $basenumb) = @_;
    my ($numb, $time, $timea, @d, @s, @o, @t, @i, @f, @time);
	my $shem = LoadFile($base.0);
    my $dba  = LoadFile($base.$basenumb);
	my $dba1 = LoadFile($base.'1');	
    my $dba2 = LoadFile($base.'2');
    my $dba3 = LoadFile($base.'3');
    push @f, $shem->[4][$_] for 0..7;
    my $size = $#{$shem->[2]};
	push @d, $shem->[2][$_]  for 0..$size;
	my $name = $#{$dba1}+1;
	my %files = ('coun' => $dba2,
		         'genr' => $dba3,
                );
    $numb = ++$#{$dba};
	($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
    for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
    $time = $basenumb.'f'.($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	$dba->[$numb][0][0] = $time;
    $dba->[$numb][0][1] = $param->{'0_1_0'};
	$dba->[$numb][0][2] = $param->{'0_2_0'};
	$dba->[$numb][0][3] = $param->{'0_3_0'}*1;
	for my $i (1..$size) {
    	if ($d[$i][3] == 1 or $d[$i][3] == 2 && $d[$i][1] == 1 or $d[$i][1] == 3) {
		    if ($d[$i][6]) {
                if ($param->{$i.'_0_0'} =~ m{$d[$i][6]}) {
	                $dba->[$numb][$i][0] =  ($1 * $d[$i][7][0] + $d[$i][7][1]) + $2;
                }
	        }
			else {
				for (0..$d[$i][2]) {
				    if ($param->{$i.'_'.$_.'_0'} =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
						$dba->[$numb][$i][$_] = $param->{$i.'_'.$_.'_0'}*1 if $param->{$i.'_'.$_.'_0'}
					}
	    	        else {
						$dba->[$numb][$i][$_] = $param->{$i.'_'.$_.'_0'} if $param->{$i.'_'.$_.'_0'}
					}
			    }
			}				
		}
		if ($d[$i][1] == 2) {
			my $dbaf = $files{$d[$i][0]};
			for my $p (0..$d[$i][2]) {
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
            for my $p (0..$d[$i][2]) {
				if ($param->{$i.'_'.$p.'_2'}) {
					my $flag = 0;
                    for (1..$#{$dba1}) {
                        if ($param->{$i.'_'.$p.'_2'} eq $dba1->[$_][1][1]) {
							$dba->[$numb][$i][$p][0] = $dba1->[$_][0][0];
							$dba->[$numb][$i][$p][1] = $dba1->[$_][1][0];
							$dba->[$numb][$i][$p][2] = $dba1->[$_][1][1];
							$dba1->[$_][0][1] = $param->{$i.'_'.$p.'_0'};
							if ($dba1->[$_][2][0] == 1) {
							    $dba->[$numb][$i][$p][3] = $dba1->[$_][0][0];
							}
							elsif ($dba1->[$_][2][0] == 0) {
							    $dba->[$numb][$i][$p][3] = 'blank';
							} 
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
						$dba->[$numb][$i][$p][3] = 'blank';
						$dba1->[$name][0][0] = '1f'.$timea;
						$dba1->[$name][0][1] = $param->{$i.'_'.$p.'_0'};
						$dba1->[$name][0][2] = $param->{$i.'_'.$p.'_3'};
						$dba1->[$name][1][0] = $param->{$i.'_'.$p.'_1'};
						$dba1->[$name][1][1] = $param->{$i.'_'.$p.'_2'};
						$dba1->[$name][2][0] = 0;
						my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
                        my $response = LWP::UserAgent->new->get('https://www.imdb.com/name/'.
		                                $param->{$i.'_'.$p.'_3'}, 'User-Agent' => $UA);
						for my $y ($response->decoded_content) {
							while ( $y =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
							    getstore($1, $f[0].$f[4].$dba1->[$name][0][0].'.jpg');
                                my $image = Image::Magick->new;
                                $image->Read($f[0].$f[4].$dba1->[$name][0][0].'.jpg'); 
                                $image->Resize(width=>170, height=>240);
                                $image->Write($f[0].$f[5].$dba1->[$name][0][0].'.jpg');
						        $image->Write($f[0].$f[6].$dba1->[$name][0][0].'.jpg');
							    $dba1->[$name][2][0] = 1;
							    $dba->[$numb][$i][$p][3] = '1f'.$timea;
							    sleep 1;
						    }
						}
						$name = $name + 1;
						sleep 1;
                    }
				}
			}
		}
	}
	my $image = Image::Magick->new; #MAKE POSTER
	$image->Read($f[0].$f[4].'0.jpg');
    $image->Resize(width=>170, height=>240);
	$image->Write($f[0].$f[5].$time.'p2.jpg');
	$image->Write($f[0].$f[6].$time.'p2.jpg');	

    my @four;
	my $x = 1;
	for (1..$dba->[$numb][0][3]) {  #MAKE MINI AND SORT IMAGES
		if ($param->{'k'.$_}) {
			my $image = Image::Magick->new;
	        $image->Read($f[0].$f[7].$_.'.jpg');
			$image->Crop(geometry=>'300x180+10+10');
            $image->Resize(width=>170, height=>100);
            $image->Write($f[0].$f[5].$time.'m'.$x.'.jpg');
			$image->Write($f[0].$f[6].$time.'m'.$x.'.jpg');
			copy ($f[0].$f[7].$_.'.jpg', $f[0].$f[5].$time.'k'.$x.'.jpg');
            copy ($f[0].$f[7].$_.'.jpg', $f[0].$f[6].$time.'k'.$x.'.jpg');
			$x++;
			push @four, $_;
		}
	}
	my (@rest, $flag);
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
		copy ($f[0].$f[7].$_.'.jpg', $f[0].$f[5].$time.'k'.$x.'.jpg');
        copy ($f[0].$f[7].$_.'.jpg', $f[0].$f[6].$time.'k'.$x.'.jpg');
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
    DumpFile($base.'1', $dba1);
	DumpFile($base.$basenumb, $dba);

	return $numb, $dba
}
sub send {
	my ($self, $base, $bnumb, $files, $numb) = @_;
	my $dbaa = LoadFile($base.$bnumb);
    my $dbab = LoadFile($base.$files);
    $dbab->[$bnumb] = $dbaa->[$numb];
    DumpFile($base.$files, $dbab);
    return $files, $bnumb
}
sub update {
    my ($self, $base, $basenumb, $numb, $name, $fild, $newl, $sfild) = @_;
	my $dba = LoadFile($base.$basenumb);
	my @f;	
	my $shem = LoadFile($base.0);
	push @f, $shem->[3][$_] for 0..6;
	my $line;
	my $imdb;
	my $eng;
	my $r;
	for (0..$#{$dba->[0]}) {
		if ($name eq $dba->[0][$_][4]) {
			$line = $_;
		}
	}
	my $basenumb0 = $dba->[0][$line][1];
	my $dba0 = LoadFile($base.$basenumb0);
	
	if ($basenumb0 == 0) {
		if ($newl =~ m{^([-+]? [\d]+  \.?[\d]* )$}x) {
			$newl = $newl * 1;
			$dba->[$numb][$line][$fild] = $newl;
		}
		else {
			$dba->[$numb][$line][$fild] = $newl;
		}
    }
	elsif ($basenumb0 == 2 or $basenumb0 == 3) {
	    for my $x (1..$#{$dba0}) {
			if ($newl eq $dba0->[$x][0][1]) {
		     	$dba->[$numb][$line][$fild][0] = $dba0->[$x][0][0];
				$dba->[$numb][$line][$fild][1] = $dba0->[$x][0][1];
				$dba->[$numb][$line][$fild][2] = $dba0->[$x][1][0];
				$dba->[$numb][$line][$fild][3] = $dba0->[$x][1][1];
			}
		}
	}
	elsif ($basenumb0 == 6) {
		for my $x (0..$#{$dba0->[0]}) {
			if ($newl eq $dba0->[0][$x][2]) {
				$dba->[$numb][$line][$fild] = $dba0->[0][$x];
			}
		}
	}
	elsif ($basenumb0 == 1) {
		my $numb0 = $#{$dba0} + 1;
		my $flag = 0;
		if ($newl =~ /^nm\d+/) {
		    for my $x (1..$#{$dba0}) {
                if ($newl eq $dba0->[$x][0][2]) {
				    if ($dba0->[$x][2][0] == 0) {
					    $dba->[$numb][$line][$fild][3] = 'blank'
				    }
				    elsif ($dba0->[$x][2][0] == 1) {
					    $dba->[$numb][$line][$fild][3] = $dba0->[$x][0][0]
				    }
				    $dba->[$numb][$line][$fild][0] = $dba0->[$x][0][0];
				    $dba->[$numb][$line][$fild][1] = $dba0->[$x][1][0];
				    $dba->[$numb][$line][$fild][2] = $dba0->[$x][1][1];
     			    $flag = 1;
		    	}
		    }
		    if ($flag == 0) {
			    my @time;
			    my $foto = 0;
			    ($time[0], $time[1], $time[2], $time[3], $time[4], $time[5]) = localtime();
                for (0..4) { $time[$_] = "0".$time[$_] if $time[$_] < 10}
                my $timea = ($time[5]-100).++$time[4].$time[3].$time[2].$time[1].$time[0];
	            $dba->[$numb][$line][$fild][0] = '1f'.$timea;
                $dba0->[$numb0][0][0] = '1f'.$timea;
				$dba0->[$numb0][0][1] = '1f'.$timea;
				$dba0->[$numb0][2][0] = 0;
				$dba->[$numb][$line][$fild][3] = 'blank';
     		    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
                $imdb = LWP::UserAgent->new->get('https://www.imdb.com/name/'.$newl, 'User-Agent' => $UA);
                for ($imdb->decoded_content) {
                    while ( $_ =~ m{class="itemprop">(.*?)</span>}mg ) { 
                        $eng = $1;
			        }
				    while ( $_ =~ m{name-poster".*?.*?\n?.*?\n.*?\n.*?\n.*?\nsrc="(.*?)"}mg) {
					    getstore($1, $f[0].$f[5].'1f'.$timea.'.jpg');
						getstore($1, $f[0].$f[6].'1f'.$timea.'.jpg');
					    $dba->[$numb][$line][$fild][3] = '1f'.$timea;
                        $dba0->[$numb0][2][0] = 1;
				    }
		        }
			    $dba->[$numb][$line][$fild][2] = $eng;
				$dba0->[$numb0][1][1] = $eng;
				$dba0->[$numb0][0][2] = $newl;
    	    }			
		}
        else {
			$dba->[$numb][$line][$fild][$sfild] = $newl;
			$dba0->[$numb0-1][1][0] = $newl;			
		}
	}
	DumpFile($base.$basenumb0, $dba0);
    DumpFile($base.$basenumb, $dba);
	return $dba
}
sub delete {
    my ($self, $base, $bnumb, $numb) = @_;
	my @f;
    my $dba = LoadFile($base. $bnumb);
	my $shem = LoadFile($base.0);
	push @f, $shem->[3][$_] for 0..6;
    unlink $f[0].$f[6].$dba->[$numb][0][0].'p2.jpg';
    unlink $f[0].$f[5].$dba->[$numb][0][0].'p2.jpg';
    for (1..$dba->[$numb][0][3]) {
        unlink $f[0].$f[6].$dba->[$numb][0][0].'k'.$_.'.jpg';
        unlink $f[0].$f[5].$dba->[$numb][0][0].'k'.$_.'.jpg';
    }
    for (1..4) {
        unlink $f[0].$f[6].$dba->[$numb][0][0].'m'.$_.'.jpg';
        unlink $f[0].$f[5].$dba->[$numb][0][0].'m'.$_.'.jpg';
    }
    my @film = @$dba;
    splice @film, $numb, 1;
    my $dba0 = [@film];
    DumpFile($base.$bnumb, $dba0);
}
sub logs {
    my $pass;
    my @chars = split( " ","A B C D E F G H" );
    foreach my $line (1..6) {
        $pass = $pass.'<hr/>';
        foreach my $char (@chars) {
            $pass = $pass.'<label><input type="radio" name="P'.$line.'"value="'.$char.'" />'.$char.'</label>' if $line != 6;
            $pass = $pass.'<label><input type="radio" name="P'.$line.'" onclick="subm1()" value="'.$char.'" />'.$char.'</label>' if $line == 6;
        }
    }
    my $text = '<div class="center_col">
                <div id="user">
                <div id="mess">Enter your password<p></div>
                <div id="dash"><p/><p/><hr><hr>'.$pass.'<hr><p/></div>
                </div></div>';
    return $text
}

__PACKAGE__->meta->make_immutable;

1;
