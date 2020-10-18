package kshisa::Controller::Root;
use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => '');

=encoding utf-8
=head1 NAME
kshisa::Controller::Root - Root Controller for kshisa
=head1 DESCRIPTION
SPA Controller
=head1 METHODS
=head2 index
The root page (/)
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my ($find, $logs, $text, $root, $glob, $mail, $imdb, $addr1, $addr2);
    my $param = $c->req->body_params;    
    my $kadr = 6;                       #PATH TO IMAGES
    my $bnumb = $param->{files} || 8;
    my $numb  = $param->{idr} || 1; 
    my $title  = $param->{tit};
    my $base  = $c->config->{'path'}.'Base/';
    my $dba   = LoadFile($base.$bnumb);
    my $total = $#{$dba};
    $numb  = 1 if $numb > $total;

    if ( $c->user_exists() ) {
        if ($param->{'logout.x'}){   #LOGOUT
            $c->logout;
            $c->response->redirect($c->uri_for("/"))
        }        
        elsif ($param->{'sch.x'}) {  #SEARCH IN NET
            if ($param->{Address} =~ /^(\d+_.*?)(tt\d+)/) {
                $glob = $c->model('Find')->find($base, $1, $2);
                $title = $glob->{'1_1_0'};
            }
            elsif ($param->{Address} =~ /^(\d+)$/) {
                if ($1 <= $total){$numb = $1}
                else {$numb = $total};
                $glob = $c->model('Data')->readds($numb, $dba);
            }
            else {
                if ($param->{Address}) {
                     $title = $param->{Address};
                    ($find, $mail, $imdb) = $c->model('Find')->base($dba, $title, $base);
                    $numb = $find->[0] || $numb;
                    $glob = $c->model('Data')->readds($numb, $dba);                    
                }
            }
        }
        elsif ($param->{'find.x'}) {
            foreach my $key (keys %$param) {
                if ($key =~ /ff(\d+_.*?)ff/) {
                    $addr1 = $1
                }
                elsif ($key =~ /(tt\d+)/) {
                    $addr2 = $1
                }
            }
            $glob = $c->model('Find')->find($base, $addr1, $addr2, $title);
        }
        else {
            if ($param->{'rt.x'}) {
		        if ($numb == $total) { $numb = 1 }
		        else { $numb = $numb + 1 }
	        }
	        elsif ($param->{'lt.x'}) {
                if ($numb == 1) { $numb = $total }
		        else { $numb = $numb - 1 }
	        }
            elsif ($param->{'insert.x'}) {
                ($numb, $dba) = $c->model('Data')->insert($base, $param, $bnumb);
                ++$total;
            }
            elsif ($param->{'del.x'}) {
                $text = 'Are you sure? <button name="delete">delete</button>'
            }
            elsif ($param->{'send.x'}) {
                ($bnumb, $numb) = $c->model('Data')->send
                ($base, $param->{idb}, $param->{files}, $numb, $param->{numb})
            }
            foreach my $key (keys %$param) {
                if ($key =~ /^bb(\d+)_(\d+)_(\d+)_(\d)$/) {
                    $dba = $c->model('Data')->update($base, $bnumb, $numb, 
                                                     $1, $2, $3, $4, $param->{$1.'_'.$2.'_'.$3})
                }
                elsif ($key eq 'change') {
                    $c->model('View')->change($numb, $base, $bnumb);
                }
                elsif ($key eq 'delete') {
                    $c->model('Data')->delete($base, $bnumb, $numb);
                }
                elsif ($key =~ /(kk\d+)/) {$kadr = $1}
                elsif ($key =~ /nn(\d+)/) {$numb = $1}
                elsif ($key =~ /pp(\d+)/) {                                    #NEW PERSON FOTO
                    $dba = $c->model('View')->person($base, $bnumb, $numb)
                }
                elsif ($key =~ /(\d+)ff(\d+)/) {                               #FROM PICTURE TO OBJECT
                    $numb = $2;
                    $bnumb = $1;
                }
                elsif ($key =~ /mm(\d)/) {
                    $kadr = $c->model('View')->mini
                    ($numb, $param, $base, $bnumb, $1, $param->{w}.'x'.$param->{h}.'+'.$param->{y}.'+'.$param->{x});            
                }
                elsif ($key =~ /((\d+)f\d+)/) {
                    $bnumb = $2;
                    $dba = LoadFile($base.$bnumb);
                    for (1..$#{$dba}) {
                        if ($dba->[$_][0][0] eq $1) {$numb = $_ }
                    }
                }
	        }
            # $logs = $c->user->get('name');
            $glob = $c->model('Data')->readds($numb, $dba);
        }    
        $root = $c->model('View')->view
        ($numb, $bnumb, $base, $dba, $glob, $kadr, $find, $mail, $imdb, $title);
    }   
    elsif ($param->{'P6'}) {                                               # PASSWORD VERIFICATION
        my $pass;
        for (1..6) { $pass = $pass.$param->{'P'.$_} if $param->{'P'.$_}}
        if ($c->authenticate({username => "kshisa",                        # LOG IN
                              password => $pass })) {
            $c->response->redirect($c->uri_for("/"))
        } 
        else {
            $c->res->body( "wrong password " )
        }
    }
    else {
        $text = $c->model('Data')->logs; 
    }
    $c->stash (
        text  => $text,
        root  => $root,
    );
}

=head2 default
Standard 404 error page
=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end
Attempt to render a view, if needed.
=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR
Hakimov Marat
=head1 LICENSE
21.07.2017
This library is not free software.
=cut

__PACKAGE__->meta->make_immutable;

1;
