package kshisa::Controller::CMS;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);
use LWP;
use LWP::Simple qw(getstore);

BEGIN { extends 'Catalyst::Controller'; }
=head1 NAME
kshisa::Controller::CMS - Catalyst Controller
=head1 DESCRIPTION
Catalyst Controller.
=head1 METHODS
=cut
=head2 index
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $param = $c->req->body_params;
    my $basenumb = $param->{file} || 0;
    my $base  = $c->config->{'Base'};
    my $Base = $c->config->{'base'};
    my $dba  = LoadFile($base.$basenumb);
    my $link = $c->config->{'link'};
    my $imgm = $c->config->{'mini'};
    my $imgk = $c->config->{'kads'};
    my $crewf = $c->config->{'crew'};
    my $imgs2 = $c->config->{'imgs2'};
    my $imgs3 = $c->config->{'imgs3'};
    my $imgs4 = $c->config->{'imgs4'};
    my $find0 = $c->config->{'find0'};
    my $findpics   = $c->config->{'find1'};
    my $findfolder = $c->config->{'find2'};
    my $find3 = $c->config->{'find3'};
    my $numb  = $param->{idr} || 1;
    my $numbl = $param->{idl} || 1;
    my $total = $#{$dba};
    
    my $mini  = '/images/mini/';
    my $kads  = '/images/kads/';
    my $foto  = '/images/crew/';
    my $find1 = '/images/find1/';
    my $newpost = '/images/find3/';

    my ($pics, $rows, $forml, $formr, $crew, $leftp, $rigtp, $panl, $text);

    if ($param->{'search.x'}) {
		my $flag = 0;
		for (1..$total) {
			if ($param->{Address} eq $dba->[$_][1][0] or 
                $param->{Address} eq $dba->[$_][1][1]) {
                $numb = $_;
				$flag = 1;
			}
		}
        if ($flag == 1) {
            $pics = $c->model('Imgs')->pics($base, $numb, $mini);
            $rows = $c->model('Imgs')->rows($base, $numb, $kads);
            ($forml, $formr, $crew) = $c->model('DSet')->readds($base, $numb, $foto); 
        }
		if ($flag == 0) {
            ($forml, $leftp, $formr, $rows, $pics) = 
            $c->model('Find')->mail($base, $param->{Address}, $findfolder, $findpics, 
                                    $param->{imdb}, $basenumb);
		}
	}
    else {
        if ($param->{'find0.x'}) {
            my $UA = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0';
            my $code = $dba->[$numb][0][2];
            my $code0 = $dba->[$numb][0][0];
            my $response = LWP::UserAgent->new->get(
               'https://www.imdb.com/title/'.$code.'/?ref_=fn_al_tt_1', 'User-Agent' => $UA);
            for ($response->decoded_content) {
                while ( $_ =~ m{>(.*?)<span.*?tt_ov_inf"\n?>(.*?)</a>}mg) {
                    $text = $1.'('.$2.')';
                }
                while ( $_ =~ m{<div class="poster">\n?<a href="(.*?)\?ref}mg) {
                    my $p = $1;
                    my $res = LWP::UserAgent->new->get('https://www.imdb.com'.$p, 'User-Agent' => $UA);
                    for ($res->decoded_content) {
                        while ( $_ =~ m{<meta itemprop="image" content="(.*?)"/>}mg) {
                            getstore($1, $find3.$code0.'p2.jpg')
                        }
                    }
                    $leftp = '<img class="image" src="/images/find3/'.$code0.'p2.jpg"/>';
                }
            }
        }
        if ($param->{'nextr.x'}) {
		    if ($numb == $total) { $numb = 1 }
		    else { $numb = $numb + 1 }
	    }
	    if ($param->{'prevr.x'}) {
            if ($numb == 1) { $numb = $total }
		    else { $numb = $numb - 1 }
	    }
        if ($param->{'nextl.x'}) {
            $numbl = $numbl + 6
	    }
	    if ($param->{'prevl.x'}) {
            $numbl = $numbl - 6
	    }        
        if ($param->{'count.x'}) {
            $numb = $param->{numb};
        }
        if ($param->{'addone.x'}) {
            $numb = $c->model('DSet')->addone($base, $param, $imgm, $imgk, $imgs2, $imgs3, 
                                              $findpics, $crewf, $Base, $imgs4, $basenumb, $find3);
            ++$total;
        }
        if ($param->{'change.x'}) {
            $c->model('DSet')->change($numb, $imgm, $imgk, $findpics, $base, $basenumb, $imgs2, $imgs3);
        }
        $pics = $c->model('Imgs')->pics($base, $numb, $mini, $basenumb, $text);
        $rows = $c->model('Imgs')->rows($base, $numb, $kads, $basenumb, $newpost);
        ($forml, $formr, $crew, $panl, $rigtp, $leftp) = $c->model('DSet')->readds
        ($base, $numb, $foto, $basenumb, $find0, $numbl);        
    }
    foreach my $key (keys %$param) {
        if ($key =~ /^(\df.\d+)/) {
            $c->model('DSet')->poster($1, $find3, $imgk, $imgm, $imgs2, $imgs3)
        }
        if ($key =~ /^(\d+_.*?)\.x/) {
            ($forml, $leftp, $formr, $rows, $pics) = 
		    $c->model('Find')->mail($base, $1, $findfolder, $findpics);
	    }
        if ($key =~ /^b(.*?)(\d)(\w)(\d)/) {
            if ($3 eq 'r') {
                my $name = $1;
                my $fild = $4;
                my $newl = $param->{$1.$2.$3.$4};
                my $rusname;
                if ($newl =~ /^nm\d+/) {
                    $rusname = 0;
                }
                else {
                    $rusname = 1;
                }
                $panl = $c->model('DSet')->correct($base, $basenumb, $numb, $name, $fild, $newl, $crewf, $imgs4, $Base, $rusname);
                ($forml, $formr, $crew, $panl, $Base) = $c->model('DSet')->readds($base, $numb, $foto, $basenumb, $find0);
            }
        }
        if ($key =~ /kk(\d+)/) {
            $pics = $c->model('Imgs')->pics($base, $numb, $mini, $basenumb, $1);
        }
        if ($key =~ /(1f\d+)/) {
            my $code = $1;
            $c->model('Imgs')->newfoto($code, $crewf, $imgs4, $base, $basenumb);
        }
        if ($key =~ /kad(\d+)/) {
            my $checkk = $1;
            ($pics, $rows) = $c->model('DSet')->newmini($numb, $param, $imgm, $imgk, $findpics, 
                                                        $base, $basenumb, $checkk, $find1, 
                                     $param->{w}.'x'.$param->{h}.'+'.$param->{y}.'+'.$param->{x});            
        }
	}
    $c->stash (
        link  => $link,
        idr   => $numb,
        panl  => $panl,
		pics  => $pics,
        rows  => $rows,
        total => $total,
        forml => $forml,
        formr => $formr,
        crew  => $crew,
        leftp => $leftp,
        rigtp => $rigtp
    );
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
