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
    my $param = $c->req->body_params;
    my $Base =  $c->config->{'Base'};
    my $User =  $c->config->{'User'};
    my $dsl = LoadFile($Base.'0');
    my ( $text, $form, $full, $ba, $lo, $ava, $name, $user, $lb, $l, $r, $rb, $micro, $rew,
         $avat, $file, $side, $right, $maxr, $rcent, $left, $maxl, $cout, $ds, $path, $usreit,
         $usrew, $love, $message, $n, $film, $best, $info);
    my $pl = 0;
    my $flag = 0;
    my $id = $param->{id} || 1;
    my $ident = 'main';

    $text = $c->model('Html')->start($User);                            # LOG IN
    $ident = 'start';

    if ($param->{New}) {                                                # NEW OR NOT USER
        ($text)         = ($c->model('Html')->yes_new($User))         if $param->{New} eq 'Yes';
        ($text, $ident) = ($c->model('Html')->not_new($User), 'pass') if $param->{New} eq 'No', ;
    }
    if ($param->{'P6'}) {                                               # PASSWORD VERIFICATION
        my $pass;
        for (1..6) { $pass = $pass.$param->{'P'.$_} if $param->{'P'.$_}}
        my $dba = LoadFile($User.0);
        if ( $pass eq 'H' ) {
            $c->response->redirect($c->uri_for("/cms"));
        }
        for (1..$dba->[0]) {
            if ( $dba->[$_][1] eq $pass ) {
                $id = $dba->[$_][0];                                     # WRONG PASSWORD?
                $flag = 1;
                last;
            }
            else {
                $flag = 2;
            }
        }
    }
    if ($flag == 2) {
        ($text, $ident) = ($c->model('Html')->wrong($User), 'pass');     # WRONG PASSWORD
    }
    if ($flag == 1) {
        ($user, $file, $side, $right, $maxr, $rcent, $ava, $lo, $ba, $left, $maxl, $cout, $info, $ds, $love, $n, $avat) = 
            $c->model('Html')->load($param, $User, $id, $Base);
        ($l, $full, $r) = 
            $c->model('Html')->info($cout, $side, $left, $right, $ds, $dsl, $info, $rew, $path, $usreit, $usrew, $lo, $ba, $n, $best, $avat, $ava, $message);
    }
    foreach my $avat (keys %$param) {                                   # CREATING NEW USER
        if ($avat =~ /ava\d+.x/) {
            $avat =~ s/\.x//;
            if ($param->{name} && $param->{mail}) {
                my $pass = $c->model('Yaml')->user($User, $param->{name}, $avat, $param->{mail});
                ($text, $ident) = ($c->model('Html')->enter($pass), 'pass')
            }
            else {
                $text = $c->model('Html')->forgot($c->config->{'User'});
            }
       }
    }

    $info = $dsl->[0][0];

    if ( $param->{'Next_l.x'} or $param->{'Last_l.x'}) {                # STEP LEFT POSTERS
        $left = $c->model('Yaml')->step($param, $left, $maxl)
    }
    elsif ( $param->{'Next_r.x'} or $param->{'Last_r.x'}) {             # STEP RIGHT POSTERS
        $right = $c->model('Yaml')->step($param, $right, $maxr);
    }

    elsif ($param->{'kadr1.x'}) { ($cout, $side, $info) = ($left+1,   0, $dsl->{1}{1}{$left+1}) }   # CENTRAL VIEW
    elsif ($param->{'kadr2.x'}) { ($cout, $side, $info) = ($left+2,   0, $dsl->{1}{1}{$left+2}) }
    elsif ($param->{'kadr3.x'}) { ($cout, $side, $info) = ($left+3,   0, $dsl->{1}{1}{$left+3}) }
    elsif ($param->{'kadr4.x'}) { ($cout, $side, $info) = ($left+4,   0, $dsl->{1}{1}{$left+4}) }
    if ($love == 0) {
        if ($param->{'kadr5.x'}) { ($cout, $side, $info) = ($right+1,  1, $ds->{1}{2}{$right+1}) }
        if ($param->{'kadr6.x'}) { ($cout, $side, $info) = ($right+2,  1, $ds->{1}{2}{$right+2}) }
        if ($param->{'kadr7.x'}) { ($cout, $side, $info) = ($right+3,  1, $ds->{1}{2}{$right+3}) }
        if ($param->{'kadr8.x'}) { ($cout, $side, $info) = ($right+4,  1, $ds->{1}{2}{$right+4}) }
    }
    if ($love == 1) {
        if ($param->{'kadr5.x'}) { ($cout, $side, $info) = ($right+1,  1, $ds->{1}{4}{$right+1}) }
        if ($param->{'kadr6.x'}) { ($cout, $side, $info) = ($right+2,  1, $ds->{1}{4}{$right+2}) }
        if ($param->{'kadr7.x'}) { ($cout, $side, $info) = ($right+3,  1, $ds->{1}{4}{$right+3}) }
        if ($param->{'kadr8.x'}) { ($cout, $side, $info) = ($right+4,  1, $ds->{1}{4}{$right+4}) }
    }
    if ( $side == 0 ) {
        if  ( $file == 0 ) {
            if ($param->{'g.x'}) {                                      # MASHINE CHOICE FOR VIEWING
                ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $User, 'g');
                ($file, $side, $info, $love) = (0, 1, $ds->{1}{2}{$cout}, 0);
            }
            if ($param->{'h.x'}) {                                      # MASHINE CHOICE OF FAVORITE
                ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $User, 'h');
                ($file, $side, $info, $love) = (0, 1, $ds->{1}{4}{$cout}, 1);
            }
        }
        if  ( $file == 1 ) {
            if ($param->{'g.x'}) {                                      # CHOICE FOR VIEWING
                ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $User, 'g');
                ($side, $info, $love) = (1, $ds->{1}{2}{$cout}, 0);
                $micro = `transmission-remote 192.168.1.5:9091 -a magnet:?xt=urn:btih:$info->{'magnet'}`;

            }
            if ($param->{'h.x'}) {                                      # CHOICE OF FAVORITE
                ($cout, $right) = $c->model('Yaml')->mashine($ds, $cout, $dsl, $User, 'h');
                ($side, $info, $love) = (1, $ds->{1}{4}{$cout}, 1);
            }
        }
    }
    if ( $side == 1 ) {
        if ($param->{'phon.x'} && $param->{rew}) {                      # SAVE USER REWIEW
            ($usreit, $usrew) = $c->model('Yaml')->rew($ds, $cout, $param, $love);
        }
        if ($param->{'phon.x'}) {
            $rew = $c->model('HTML')->rew($ds, $cout);                  # USER REWIEW PANEL
        }
        if ($param->{'del.x'} && $love == 0) {                          # DELETE FOR VIEWING
            ($cout, $side, $info, $left) = $c->model('Yaml')->del($ds, $dsl, $cout, $maxr, 2);
        }
        if ($param->{'del.x'} && $love == 1) {                          # DELETE OF FAVORITE
            ($cout, $side, $info, $left) = $c->model('Yaml')->del($ds, $dsl, $cout, $maxr, 4);
        }
    }
    if ($param->{Address}) {                                            # FIND IN BASE BY NAME
        if ($param->{Address} =~ /^\d+$/) {
            ($message, $cout, $side, $info, $left) = $c->model('Yaml')->numb($param->{Address}, $dsl);
        }
        else {
            my ($find, $file1, $cout1, $side1, $info1, $left1 ) = $c->model('Yaml')->find(lc $param->{Address}, $dsl);
            if ($find == 0) {
                $message = 'No result in the database';
            }
            else {
                ($file, $cout, $side, $info, $left) = ($file1, $cout1, $side1, $info1, $left1)
            }
        }
    }
    if ($param->{'Find_l.x'}) {
        $micro = $c->model('Html')->micro($dsl, $param->{'year'}+ 0);
    }

    foreach my $key (keys %$param) {                                    # FIND ALL OF THAT YEAR
        if ($key =~ /^\d+$/) {
            $micro = $c->model('Html')->micro($dsl, $key);
        }
        if ($key =~ /^(\d+)\.x/) {                                      # ONE FROM FILMS OF THAT YEAR
            ($micro, $side, $cout, $info) = ('', 0, $1, $dsl->{1}{1}{$1});
            my $p = $cout/4 - int($cout/4);
            if    ( $p == 0)    { $left = $cout-4}
            elsif ( $p == 0.75) { $left = $cout-3}
            elsif ( $p == 0.5)  { $left = $cout-2}
            elsif ( $p == 0.25) { $left = $cout-1}
        }

    }

    $full = '' if $text;
    # my $year =  $dsl->{1}{1}{$left}{year};
    $c->stash (
        # year     => $year,
        user     => $user,                                              # HEADER
        micro    => $micro,                                             # ALLPICTURES
        l        => $lb.$l,                                             # LEFT PICTURES
        full     => $full,                                              # CENTER-FULLINFO
        text     => $text,                                              # HTML CODE
        r        => $r,                                                 # RIGHT PICTURES
        forma    => $form,
        ident    => $ident,
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
