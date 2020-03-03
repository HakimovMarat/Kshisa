package kshisa::Schema::Result::Film;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

kshisa::Schema::Result::Film

=cut

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<films>

=cut

__PACKAGE__->table("films");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 runame

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 orname

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 country

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 genre

  data_type: 'varchar'
  is_nullable: 0
  size: 15

=head2 time

  data_type: 'integer'
  is_nullable: 0

=head2 reit

  data_type: 'integer'
  is_nullable: 1

=head2 director

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor1

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor2

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor3

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor4

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 actor5

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 magnet1

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 poster

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 format

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 size

  data_type: 'integer'
  is_nullable: 0

=head2 loctime

  data_type: 'integer'
  is_nullable: 0

=head2 kadr1

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 kadr2

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 kadr3

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  "loctime",
  { data_type => "integer", is_nullable => 0 },
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "runame",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "orname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "coun",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "genr",
  { data_type => "varchar", is_nullable => 0, size => 15 },
  "time",
  { data_type => "integer", is_nullable => 0 },
  "reit",
  { data_type => "integer", is_nullable => 1 },
  "director",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor1",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor2",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor3",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor4",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "actor5",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "kad0",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "kad1",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "kad2",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "kad3",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "kad4",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "review",
  { data_type => "varchar", is_nullable => 0, size => 2000 },
  "magnet1",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "format",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "size",
  { data_type => "integer", is_nullable => 0 },
  "No",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("code", ["code"]);
__PACKAGE__->meta->make_immutable;
1;
