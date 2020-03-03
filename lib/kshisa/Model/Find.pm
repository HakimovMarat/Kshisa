package kshisa::Model::Find;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use LWP;
use LWP::Simple qw(getstore);

extends 'Catalyst::Model';
=head1 NAME
kshisa::Model::Find - Catalyst Model
=head1 DESCRIPTION
Catalyst Model.
=cut

sub mail {
    my ($self, $base, $find, $findfolder, $findpics, $parimdb, $basenumb) = @_;
    my ($forml, $formr, $leftp, @d, @s, @t, $response, @names, %crewre, @title, 
        $pics, $resimdb, $resimdb0, @code, @name, @year, $eng, $text, $reit, $imdb);
    my $shem  = LoadFile($base.'shem');
    my $snip  = LoadFile($base.'snip');
    my $shemsize = $#{$shem->[0]};
    push @d, $shem->[0][$_]  for 0..$shemsize;
    push @s, $snip->[0][0][$_] for 0..7;
    push @t, $snip->[0][2][$_] for 0..9;
    unlink glob "$findfolder*.*";
    unlink glob "$findpics*.*";

    my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
    if ($find =~ /^(\d+_.*?)/) {
	    $response = LWP::UserAgent->new->get($d[0][6][1].$find, 'User-Agent' => $UA);
        #getstore($d[0][6][3].$find, $findfolder.$find.'.jpg')
	}
    else {
        $response = LWP::UserAgent->new->get($d[0][6][0].$find, 'User-Agent' => $UA);
        for ($response->decoded_content) {
            while ( $_ =~ m{$d[0][6][2]}mg) {
                getstore($d[0][6][3].$1, $findfolder.$2.'.jpg') if $1;
				push @names, $2;
            }
        }
		$response = LWP::UserAgent->new->get($d[0][6][1].$names[0], 'User-Agent' => $UA);
    }
    my $x = 0;
    for (@names) {
	    $leftp = $leftp.'<div class="numb">'.($x = $x + 1).
				        '</div><a title="'.$_.'">
						 <input type="image" class="image"
							   name="'.$_.'"
							   src="/images/find2/'.$_.'.jpg"></a>' if $_;
 	}
    
    my $imgs = 0;
    for my $i (0..$shemsize) {
        my $x = 0;
        my $name = $d[$i][0];
        my $rest = $d[$i][2];
        for ($response->decoded_content) {
            while ( $_ =~ m{$d[$i][4]}mg) {
                my $pers = $1;
                while ( $pers =~ m{$d[$i][5]}mg) {
                    my $str = $1;
                    if ($i == 0) {
                        ++$imgs;
                        if ($imgs%2 == 0) {
                            getstore($str, $findpics.($x = $x + 1).'.jpg');
                        }
                    }
                    else {
                        if ($d[$i][1] == 3) {
                            $text = $str;
                        }    
                        else {
                            if ($d[$i][3] == 2 or $d[$i][3] == 3) {
                                if ($name eq 'name') {
                                    push @title, $str;
                                    if ($title[1]) {
                                        $resimdb = LWP::UserAgent->new->get($d[0][6][6].$title[1].'&ref_=nv_sr_sm', 'User-Agent' => $UA);
                                        	for ($resimdb->decoded_content) {
                                                while ( $_ =~ m{$d[0][6][7]}mg ) {
			                                        push @code, $1;
			                                        push @name, $2;
			                                        push @year, $3;
                                                }
                                           }
                                        if ($parimdb) {
                                            $imdb = $parimdb
                                        }
                                        else {
                                            $imdb = $code[0]
                                        }
                                        $resimdb0 = LWP::UserAgent->new->get($d[0][6][10].$imdb.$d[0][6][11], 'User-Agent' => $UA);
                                        for ($resimdb0->decoded_content) {
                                            while ( $_ =~ m{$d[0][6][12]}mg) {
                                                $reit = $1;
                                            }
                                        }
                                        $resimdb = LWP::UserAgent->new->get($d[0][6][8].$imdb.'/fullcredits', 'User-Agent' => $UA);
                                    }
                                }
                                if ($i == 2) {$str = $reit}
                                $forml = $forml.$s[0].$s[1].$s[2].$name.
				                                $s[3].$name.($x=++$x).'l'.$s[4].
					                            $str.$s[5].$s[6];
			    	            $formr = $formr.$s[0].$s[1].$s[2].$name.
				                                $s[3].$name.($x).'r'.$s[4].
					                            $s[5].$s[6];
                            }
		                    if ($d[$i][3] == 1) {
		     		            $forml = $forml.$s[0].$s[1].$s[2].$name.
				                                $s[3].$name.($x=++$x).'l1'.$s[4].
					                            $2.$s[5].$s[6];
			    	            $formr = $formr.$s[0].$s[1].$s[2].$name.
				                                $s[3].$name.($x).'r'.$s[4].
					                            $str.$s[5].$s[6];
			                    my $resmail = LWP::UserAgent->new->get($d[0][6][4].$1, 'User-Agent' => $UA);
			                    sleep 1;
			                    for ($resmail->decoded_content) {
                                    while ($_ =~ m{$d[0][6][5]}mg) {
					                    $eng = $1;
                                        $forml = $forml.$s[0].$s[1].$s[2].$name.
		 		                                        $s[3].$name.($x).'l2'.$s[4].
					                                    $1.$s[5].$s[6];
		                                $formr = $formr.$s[0].$s[1].$s[2].$name.
				                                        $s[3].$name.($x).'r'.$s[4].
					                                    $s[5].$s[6];
                                    }
                                    
                                }
                                my $field;
                                my $flag = 0;
                                for ($resimdb->decoded_content) {
                                    while ( $_ =~ m{$d[0][6][9]}mg) {
                                        if ($2 eq $eng and $flag == 0) {
                                            $field = $1;
                                            $flag++
                                        }
                                    }        
                                }            
                                $forml = $forml.$s[0].$s[1].$s[2].$name.
		 		                                $s[3].$name.($x).'l3'.$s[4].
					                            $field.$s[5].$s[6];
	                            $formr = $formr.$s[0].$s[1].$s[2].$name.
				                                $s[3].$name.($x).'r'.$s[4].
					                            $s[5].$s[6]; 
                                --$rest;
                            }
                        }
                    }
                }
            }
        }
        if ($d[$i][3] == 1) {
            for my $x (($d[$i][2]-$rest+1)..$d[$i][2]) {
                for my $y (1..3) {
                    $forml = $forml.$s[0].$s[1].$s[2].$name.$s[3].$name.($x).'l'.$y.$s[4].$s[5].$s[6];
	                $formr = $formr.$s[0].$s[1].$s[2].$name.$s[3].$name.($x).'r'.$y.$s[4].$s[5].$s[6];
                }
            }            
        }
    } 
    my $name = $d[13][0];
    $forml = $forml.$t[0].$t[1].$t[2].$t[3].$name.$t[4].$t[8].$t[9].$t[0].$t[1].$t[5].$name.'1l'.$t[6].
                    $text.$t[7].$t[8].$t[9];    
	$formr = $formr.$t[0].$t[1].$t[2].$t[3].$name.$t[4].$t[8].$t[9].$t[0].$t[1].$t[5].$name.'1r'.$t[6].
					      $t[7].$t[8].$t[9]; 
    $forml = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'3l'.$s[4].(($imgs-3)/2).$s[5].$s[6].$forml;
    $formr = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'3r'.$s[4].$s[5].$s[6].$formr;
    $forml = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'2l'.$s[4].$imdb.$s[5].$s[6].$forml;
    $formr = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'2r'.$s[4].$s[5].$s[6].$formr;
    $forml = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'1l'.$s[4].($names[0] || $find).$s[5].$s[6].$forml;
    $formr = $s[0].$s[1].$s[2].$d[0][0].$s[3].$d[0][0].'1r'.$s[4].$s[5].$s[6].$formr;

	opendir (my $dh, $findpics);
	my @files = grep { !/^\./ } readdir($dh);
	$_ =~ s/.jpg// for (@files);   
    my $rows;
    for (2..$#files+1) {
        $rows = $rows.'<img class="image"name="'.$_.'"src="/images/find1/'.$_.'.jpg"/>
                           <input type="checkbox" name="k'.$_.'" checked/>
                           <input type="checkbox" id="chek" name="m'.$_.'"/>';            
    }
    $rows = $rows.'<input type="image" name="addone" src="/images/butt/chek.png">
                   <input type="text"  name="file"   class="address" value="'.$basenumb.'" size="1"><hr>';
    $pics = '<div id="imdb">'.$name[1].''.$year[1].'
             <input id="chek" type="checkbox" name = 1" checked/></div>';

    return $forml, $leftp, $formr, $rows, $pics
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
