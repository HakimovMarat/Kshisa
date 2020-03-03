package kshisa::Model::Mongodb;
use Moose;
use YAML::Any qw(LoadFile DumpFile);
use namespace::autoclean;
extends 'Catalyst::Model::MongoDB';
 
__PACKAGE__->config(
    'host' => '127.0.0.1',
    'port' => '27017',
    'dbname' => 'test',
);
sub mongo { 
    my ($self, $userPath, $cols, $select, ) = @_;
    my $ds = LoadFile($userPath.'best');
    for (1..100) {
        $self->c('kshisa')->insert_one( {
            code => '<img src="/images/imgs/'.$ds->{$_}{'code'}.'kad3.jpg">',
        });
    }
=cut
    my $all_users = $self->c('kshisa')->find();
    my $message;
    while (my $user = $all_users->next) {
        $message = $user->{'actor1'};
    }
    return $message
=cut
}
=head1 NAME

kshisa::Model::Mongodb - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
