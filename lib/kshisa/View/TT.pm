package kshisa::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    CATALYST_VAR => 'c',
    ENCODING     => 'utf-8',
);

=head1 NAME

Kshisa::View::TT - TT View for Kshisa

=head1 DESCRIPTION

TT View for Kshisa.

=head1 SEE ALSO

L<Kshisatv>

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
