package kshisa::Controller::CMS;
use Moose;
use namespace::autoclean;
use YAML::Any qw(LoadFile DumpFile);

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
    my ($pics, $forml, $formr, $leftp, $rigtp, $panl, @finds);
    my $kadr = 6;  
    my $param = $c->req->body_params;
    my $bnumb = $param->{files} || 8;    
    my $numb  = $param->{idr} || 1; 
    my $base  = '/home/marat/Base/';
    my $dba   = LoadFile($base.$bnumb);
    my $total = $#{$dba};
    if ($param->{'search.x'} && $param->{where} eq 'mail') {        
        ($forml, $leftp, $formr, $pics) = 
        $c->model('Find')->mail($base, $param->{Address}, $bnumb)
    }
    else {
        if ($param->{'search.x'} && $param->{where} eq 'base') {
            @finds = $c->model('Find')->base($base, $param->{Address}, $bnumb);
            $numb = $finds[0]
        }        
        elsif ($param->{'find0.x'}) {
            ($bnumb, $numb) = $c->model('AddOne')->send
            ($base, $param->{idb}, $param->{files}, $numb, $param->{numb})
        }
        elsif ($param->{'nextr.x'}) {
		    if ($numb == $total) { $numb = 1 }
		    else { $numb = $numb + 1 }
	    }
	    elsif ($param->{'prevr.x'}) {
            if ($numb == 1) { $numb = $total }
		    else { $numb = $numb - 1 }
	    }
        elsif ($param->{'count.x'}) {
            if ($param->{numb} <= $total){$numb = $param->{numb}}
            else {$numb = $total}
        }
        elsif ($param->{'change.x'}) {
            $c->model('AddOne')->change($numb, $base, $bnumb);
        }   
        elsif ($param->{'addone.x'}) {
            $numb = $c->model('AddOne')->add($base, $param, $bnumb);
            ++$total;
        }
        elsif ($param->{'del.x'}) {
            $c->model('AddOne')->delete($base, $bnumb, $numb);
        }
        elsif ($param->{'add1.x'}) {
            $rigtp = $c->model('AddOne')->addone($base, $param, $bnumb);
            ++$total;
        }
        foreach my $key (keys %$param) {
            if ($key =~ /^b(.*?)(\d+)(\w)(\d+)/) {
                $c->model('AddOne')->correct
                ($base, $bnumb, $numb, $1, $2, $param->{$1.$2.$3.$4}, $4)
            }
            if ($key =~ /(kk\d+)/) {$kadr = $1}
            if ($key =~ /nn(\d+)/) {$numb = $1}
            if ($key =~ /pp(\d+)/) {$c->model('AddOne')->newfoto($base, $bnumb, $numb)}
            if ($key =~ /ff(\d+)/) {
                $numb = $1;
                $bnumb = 8;
            }
            if ($key =~ /mm(\d)/) {
                $kadr = $c->model('AddOne')->newmini
                ($numb, $param, $base, $bnumb, $1, $param->{w}.'x'.$param->{h}.'+'.$param->{y}.'+'.$param->{x});            
            }        
            if ($key =~ /(1f\d+)/) {
                $bnumb = 1;
                my $dba1 = LoadFile($base.1);
                for (1..$#{$dba1}) {
                    if ($dba1->[$_][0][0] eq $1) {$numb = $_ }
                }
            }
	    }
        ($forml, $formr, $panl, $rigtp, $pics) = 
        $c->model('DSet')->readds($base, $numb, $bnumb, $kadr, \@finds);   
    }
    $c->stash (
        panel => $panl,
        rigtp => $rigtp,
        forml => $forml,
		pices => $pics,
        formr => $formr      
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
