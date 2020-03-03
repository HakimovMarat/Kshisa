package kshisa::Controller::REST;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
    default => 'application/json',
);

=head1 NAME
kshisa::Controller::REST - Catalyst Controller
=head1 DESCRIPTION
Ctalyst Controller.
=head1 METHODS
=cut
=head2 index
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Kshisatv::Controller::REST in REST.');
}
sub thing :Local :ActionClass('REST') { }
    
sub thing_PUT {
    my ( $self, $c ) = @_;
    my ( $filename, $rs );
    
    my $user = $c->req->data->{user};
    my $args1 = $c->req->data->{n};
    my $procent = $c->req->data->{procent};
    my $args4 = $c->req->data->{ids};

    if ($args1 eq '1') {
        $rs = $c->model('DB')->resultset('User')->find({username => $user});
        $rs->update({'f1' => $procent});
        $filename = '0000';
    }
    elsif ($args1 eq '0') {
        $rs = $c->model('DB')->resultset('User')->find({username => $user});
        $filename = $rs->f1;
        $self->status_ok(
            $c,
            entity => {
                filename => "magnet:?xt=urn:btih:$filename",
            }
        );
    }

}
=encoding utf8
=head1 AUTHOR
Hakimov Marat
=head1 LICENSE
This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.
=cut

__PACKAGE__->meta->make_immutable;

1;
