package kshisa::Model::Html;
use Moose;
use namespace::autoclean;
use utf8;
use YAML::Any qw(LoadFile DumpFile);
extends 'Catalyst::Model';

=head1 NAME

kshisa::Model::Html - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Marat,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

my $s0 = '<img class="';                                                # SNIPETS
my $s1 = '"><input class="';
my $s2 = '" type="image" name="';
my $s3 = '" src="/images/mini/';
my $s4 = '.jpg" /></a>';
my $s5 = '<div class="numb">';
my $s6 = '</div>';
my $s7 = '" src="/images/butt/';
my $s8 = '<a title="';
my $s9 = '.png" /></a>';
my $s10 = '" src="/images/avat/';
sub _code {
    my (@codes, $codes);
    my $dba = LoadFile('/home/marat/Base/0');
    my $size = $#{$dba};
    push @codes, $dba->[$_][0][0] for (1..$size);
    foreach (@codes) {
        $codes = $codes.'<img src="/images/kads/'.$_.'k1.jpg">';
    }
    return $codes;
}
sub _char {
    my $pass;
    my @chars = split( " ","A B C D E F G H" );
    foreach my $line (1..6) {
        $pass = $pass.'<hr/>';
        foreach my $char (@chars) {
            $pass = $pass.'<label><input type="radio" name="P'.$line.'"value="'.$char.'" />'.$char.'</label>' if $line != 6;
            $pass = $pass.'<label><input type="radio" name="P'.$line.'" onclick="subm1()" value="'.$char.'" />'.$char.'</label>' if $line == 6;
        }
    }
    return $pass
}
sub start {
    my ( $self, $userPath ) = @_;
    my $text = '<div class="center_col">
                  <div id="user">
                      <div id="mess">New User? &nbsp&nbsp&nbsp
                        <input name="New" onclick="subm()" value="Yes" id="NY" type="radio">
                        <label for="NY">Yes&nbsp;&nbsp;</label>
                        <input name="New" onclick="subm()" value="No" id="NN" type="radio">
                        <label for="NN">No&nbsp;&nbsp;</label>
                      </div>
                     <div class="fadein">'._code().'</div> 
                    </div>
                </div>';
    return $text
}
sub not_new {
    my $text = '<div class="center_col">
                <div id="user">
                <div id="mess">Enter your password<p></div>
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><p/></div>
                </div></div>';
    return $text
}
sub yes_new {
    my ( $self, $userPath ) = @_;
    my $avat;
    my @ava = split( " ","001 002 003 004 005 006 007 008 009 010 011 012 013" );
    foreach (@ava) {
        $avat = $avat.'<input type="image" class="ava" src="/images/avat/ava'.$_.'.jpg" name="ava'.$_.'" />&nbsp';
    }
    my $text = '<div class="center_col">
                <div id="user"><div class="fadein">'._code($userPath).'</div>
                <div id="mess"><p>
                 1. Enter Your Name: &nbsp&nbsp&nbsp&nbsp 2. Enter Your Email:<p>
                 <input type="text" name="name" class="userid"/>&nbsp&nbsp&nbsp&nbsp
                 <input type="text" name="mail" class="userid"/><p>
                 3. Choose Your Avatar<p>'.$avat.'</div></div></div>';
    return $text
}
sub enter {
    my ( $self, $pass ) = @_;
    my $text = '<div class="center_col">
                <div id="user">
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><hr><hr><p/></div>
                <div id="mess">
                Welcome to Kshisa!<p>
                Your  oun video collection<p>
                Your password:<p>'.$pass.
                '<p>Enter your password on dashboard<p>
                check buttons before letter of your password<p>
                from top to bottom
                </div></div></div>';
    return $text
}
sub forgot {
    my ( $self, $userPath ) = @_;
    my $avat;
    my @ava = split( " ","001 002 003 004 005 006 007 008 009 010 011 012" );
    foreach (@ava) {
        $avat = $avat.'<input type="image" class="ava" src="/images/avat/ava'.$_.'.jpg" name="ava'.$_.'" />&nbsp';
    }
    my $text = '<hr>
                <div id="user"><div class="fadein">'._code($userPath).'</div>
                <div id="mess"><p>
                You forgot to type your name or email<p>
                 1. Enter Your Name: &nbsp&nbsp&nbsp&nbsp 2. Enter Your Email:<p>
                 <input type="text" name="name" class="userid"/>&nbsp&nbsp&nbsp&nbsp
                 <input type="text" name="mail" class="userid"/><p>
                 3. Choose Your Avatar<p>'.$avat.'</div>';
    return $text
}
sub wrong {
    my $text = '<hr>
                <div id="user">
                <div id="dash"><p/><p/><hr><hr>'._char.'<hr><hr><hr><p/></div>
                <div id="mess">Wrong password</div></div>';
    return $text
}
sub micro {
    my ($self, $ds, $key) = @_;
    my ($n, $micro);
    for(1..$ds->{1}{1}{0}) {
        if ($key eq $ds->{1}{1}{$_}{'year'}) {
            $micro = $micro.$s8.$ds->{1}{1}{$_}{'runame'}.$s1.'imageall'.$s2.$_.$s3.$ds->{1}{1}{$_}{'code'}.'kad0'.$s4;
            $n++;
        }
    }
    $micro = '<hr><div id="pics">'.$key.$micro.'</div>';
    return $micro
}
sub rew {
    my ($self, $ds, $cout, $id) = @_;
    my $radio;
    $radio = $radio.'<label><input type="radio" name="usreit" value="'.$_.'" />'.$_.'</label>' for ( 1..9 );
    my $rew = '&nbsp;&nbsp;&nbsp;<textarea name="rew" cols="80" rows="4" placeholder="Review">'.
    $ds->{1}{2}{$cout}{$id}{'rew'}.'</textarea>'.'<p>IMDB ='.
    $ds->{1}{2}{$cout}{'reit'}.'&nbsp;&nbsp;&nbsp;Your ='.$radio.'</p>';
    return $rew 
}
sub load {
    my ($self, $param, $User, $id, $Base) = @_;
    my $ds  = LoadFile($User.1);                                # LOAD USERFILE #id
    my $dba = LoadFile($Base.0);
    my ($name, $avat, $file, $side, $rcent, $love);
    my ($ba, $lo, $left, $maxl, $right, $maxr, $cout, $info, $n);
#    my ($name, $avat) = ($ds->{0}{0}, $ds->{0}{1});
    
# USER
    my $ava = '<div class="pulse1"></div><div class="pulse2"></div><div class="icon">'.
                $s8.$name.$s1."buts".$s2.'avat" src="/images/avat/'.$avat.$s9.'</div>';
    
    my $user = '<input type="hidden" name="id" value="'.$id.'" />';
    
#    my ($file, $side, $rcent, $love) = ($ds->{1}{0}{0}, $ds->{1}{0}{1}, $ds->{1}{0}{0}, $ds->{1}{0}{10});

    $ba = $s8.$s1.$s2.'au'.$s7.'au1'.$s4    if $file == 0;
    $ba = $s8.$s1.$s2.'ba'.$s7.'ba1'.$s4    if $file == 1;
    
    $lo = $s8.$s1.$s2.'se'.$s7.'glaz'.$s4    if $love == 0;    
    $lo = $s8.$s1.$s2.'lo'.$s7.'fav1'.$s4    if $love == 1;

    ($file, $ds->{1}{0}{0}, $ba)  = (1, 1, $s8.$s1.$s2.'ba'.$s7.'ba1'.$s4)  if $param->{'au.x'};
    ($file, $ds->{1}{0}{0}, $ba)  = (0, 0, $s8.$s1.$s2.'au'.$s7.'au1'.$s4)  if $param->{'ba.x'};
    
    ($love, $ds->{1}{0}{10}, $lo)  = (0, 0, $s8.$s1.$s2.'se'.$s7.'glaz'.$s4)  if $param->{'lo.x'};
    ($love, $ds->{1}{0}{10}, $lo)  = (1, 1, $s8.$s1.$s2.'lo'.$s7.'fav1'.$s4)  if $param->{'se.x'};

    if ($file == 0) {
        ($left, $maxl) = ($ds->[1], $#{$dba});
        if ($side == 0) {
            $cout = $ds->[2];
            
        }
    }
    if ($file == 1) {
        ($left) = ($ds->{1}{0}{6});                                     
        if ($side == 0) {
            $cout = $ds->{1}{0}{7};
        }
    }
    if ($love == 0) {
        ($right, $maxr, $n) = ($ds->[3],  $#{$dba}, 2);
        if ($side == 1) {
            $cout = $ds->{1}{0}{5};
            $info = $ds->{1}{2}{$cout};
            
        }
    }
    if ($love == 1) {
        ($right, $maxr, $n) = ($ds->{1}{0}{8},  $ds->{1}{4}{0}, 4);
        if ($side == 1) {
            $cout = $ds->{1}{0}{9};
            $info = $ds->{1}{4}{$cout};
        }
    }

    return $user, $file, $side, $right, $maxr, $rcent, $ava, $lo, $ba, 
           $left, $maxl, $cout, $info, $ds, $love, $n, $avat;
}
sub friends {
    my ($self, $userPath, $id) = @_;
    my ($ds)  = LoadFile($userPath.$id); 
    my $best;
    for(1..8) {
        my $code = $ds->{1}{2}{$_}{'code'} || 'blank';                 # 8 FIRST CODES THE USER
        $best = $best.'<input class="kadr2" type="image" src="/images/imgs/'.$code.'kad0.jpg" name="'.$_.'" />';
    }
    return $best
}
sub info {
    my ($self, $cout, $side, $left, $rigt, $ds, $dsl, $info, $rew, $path, $usreit, 
    $usrew, $lo, $ba, $n, $best, $avat, $ava, $message) = @_;

    if ($side == 1) {
        for (1..$info->{0}) { 
            $usrew  = $usrew.'<p>'.'['.$info->{$_}{'time'}.']&nbsp;&nbsp;'.$info->{$_}{'rewi'}.'<hr>';
        }
        $usreit = $info->{'usreit'};
    }

    my $code = $info->{code};
    
    my $clock1 = ($info->{time}-$info->{time}%60)/60;                   # START-STOP CLOCK
    $clock1 = ( $clock1 < 10 ? "0" : "" ).$clock1;
    my $clock2 = $info->{time}%60;
    $clock2 = ( $clock2 < 10 ? "0" : "" ).$clock2;
    my $clock = 'BEGIN <ul><li class="hours"></li><li class="point">:</li><li class="min"> </li>            
                 <li class="point">:</li><li class="sec"> </li></ul><span id="hours">'.$clock1.'</span>
                 ::<span id="minut">'.$clock2.'</H2></span><ul><li class="hours1"></li><li class="point">
                 :</li><li class="min1"></li><li class="point">:</li><li class="sec"> </li></ul> END';

    my $title = 'orname';
    my $buts;
    #$buts = '<span>'.$s8.$s1.$s2.'g'.$s7.'g'.$s4.'&nbsp;&nbsp'.$s8.$s1.$s2.'h'.$s7.'h'.$s9.'&nbsp;&nbsp</span>'if $side == 0;
    #$buts = '<span>'.$s8.$s1.$s2.'phon'.$s7.'phon.png" /> &nbsp;&nbsp'.$s8.$s1.$s2.'del'.$s7.'del'.$s4.'&nbsp;&nbsp</span>' if $side == 1;

    my $pl = '<img id="kshisa" name="kshisa" src="/images/buttons/kshisa4.png"/>
              <input id="Address" name="Address" type="text" value="'.$message.'">
              <div id="Avat">'.$ava.'</div><hr>';

    my ( $ch, $check, $p, $k );
    $ch = 1 if $left+1  == $cout && $side == 0;                         # CHECK
    $ch = 2 if $left+2  == $cout && $side == 0;
    $ch = 3 if $left+3  == $cout && $side == 0;
    $ch = 4 if $left+4  == $cout && $side == 0;
    $ch = 5 if $rigt+1  == $cout && $side == 1;
    $ch = 6 if $rigt+2  == $cout && $side == 1;
    $ch = 7 if $rigt+3  == $cout && $side == 1;
    $ch = 8 if $rigt+4  == $cout && $side == 1;

    $check = '<img id="check'.$ch.'" src="/images/buttons/Check.png" />' if $ch;

    my $lb = '<span>'.$s8.$s1.$s2.'Last_l'.$s7.'prev'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'Find_l'.$s7.'find'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'g'.$s7.'find'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'Next_l'.$s7.'next'.$s4.'</span>';
    my $rb = '<span>'.$s8.$s1.$s2.'Last_r'.$s7.'prev'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'del'.$s7.'find'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'phon'.$s7.'find'.$s4.'</span>'.
             '<span>'.$s8.$s1.$s2.'Next_r'.$s7.'next'.$s4.'</span>';

    my $p1 = my $p2 = my $p3 = my $p4 = my $p5 = my $p6 = my $p7 = my $p8 =
    $s0.'image'.$s3.'blankkad0'.$s4; 

    my ($full, $l, $r);
    if ($best) {
        $p = $s0.'post" src="/images/avat/'.$avat.'.png" />';           # POSTER
        $k = $best;
        $p1 = $s8.$s1.'image'.$s2.'frnd1'.$s10.$ds->{2}{1}{2}.$s4 if $ds->{2}{1}{2};
        $p2 = $s8.$s1.'image'.$s2.'frnd2'.$s10.$ds->{2}{2}{2}.$s4 if $ds->{2}{2}{2};
        $p3 = $s8.$s1.'image'.$s2.'frnd3'.$s10.$ds->{2}{3}{2}.$s4 if $ds->{2}{3}{2};
        $p4 = $s8.$s1.'image'.$s2.'frnd4'.$s10.$ds->{2}{4}{2}.$s4 if $ds->{2}{4}{2};
        $l = $s5.(1).$s6.$p1.$s5.(2).$s6.$p2.$s5.(3).$s6.$p3.$s5.(4).$s6;           # LEFT PICS
        $p1 = $s8.$s1.'image'.$s2.'frnd1'.$s10.$ds->{3}{1}{2}.$s4 if $ds->{3}{1}{2};
        $p2 = $s8.$s1.'image'.$s2.'frnd2'.$s10.$ds->{3}{2}{2}.$s4 if $ds->{3}{2}{2};
        $p3 = $s8.$s1.'image'.$s2.'frnd3'.$s10.$ds->{3}{3}{2}.$s4 if $ds->{3}{3}{2};
        $p4 = $s8.$s1.'image'.$s2.'frnd4'.$s10.$ds->{3}{4}{2}.$s4 if $ds->{3}{4}{2};
        $r = $s5.(1).$s6.$p5.$s5.(2).$s6.$p6.$s5.(3).$s6.$p7.$s5.(4).$s6.$check; 
        $full = $p.'<div class="foto">'.$k.'<hr></div></div><div class="right_col">';
    }  
    else {
        $p = $s0.'post'.$s3.$code.'kad0.jpg"/>';                        # POSTER
        $k = $s0.'kadr'.$s3.$code.'kad1.jpg"/>'.                        # FRAMES
             $s0.'kadr'.$s3.$code.'kad2.jpg"/>'.
             $s0.'kadr'.$s3.$code.'kad3.jpg"/>'.
             $s0.'kadr'.$s3.$code.'kad4.jpg"/>';
    
        $p1 = $s8.$dsl->[$left+1][1][1].$s1.'image'.$s2.'kadr1'.$s3.$dsl->[$left+1][0][0].'m0'.$s4;
        $p2 = $s8.$dsl->[$left+2][1][1].$s1.'image'.$s2.'kadr2'.$s3.$dsl->[$left+2][0][0].'m0'.$s4;
        $p3 = $s8.$dsl->[$left+3][1][1].$s1.'image'.$s2.'kadr3'.$s3.$dsl->[$left+3][0][0].'m0'.$s4;
        $p4 = $s8.$dsl->[$left+4][1][1].$s1.'image'.$s2.'kadr4'.$s3.$dsl->[$left+4][0][0].'m0'.$s4;
        $l = $s5.($left+1).'/'.$#{$dsl}.$s6.$p1.
             $s5.($left+2).$s6.$p2.
             $s5.($left+3).$s6.$p3.
             $s5.($left+4).$s6.$p4.$s5.$s6;        # LEFT PICS
    
        $p5 = $s8.$dsl->[$rigt+1][1][1].$s1.'image'.$s2.'kadr5'.$s3.$dsl->[$rigt+1][0][0].'m0.jpg" /></a>';
        $p6 = $s8.$dsl->[$rigt+2][1][1].$s1.'image'.$s2.'kadr5'.$s3.$dsl->[$rigt+2][0][0].'m0.jpg" /></a>';
        $p7 = $s8.$dsl->[$rigt+3][1][1].$s1.'image'.$s2.'kadr5'.$s3.$dsl->[$rigt+3][0][0].'m0.jpg" /></a>';
        $p8 = $s8.$dsl->[$rigt+4][1][1].$s1.'image'.$s2.'kadr5'.$s3.$dsl->[$rigt+4][0][0].'m0.jpg" /></a>';
        $r = $s5.($rigt+1).$s6.$p5.$s5.($rigt+2).$s6.$p6.$s5.($rigt+3).$s6.$p7.$s5.($rigt+4).$s6.$p8.$s5.$s6.$check;         # RIGT PICS
    
        $full = '<div class="center_col">'.$pl.'
                    <div id="scrn">'.$p.
                       '<div class="foto">'.
                            $k.
                        '</div>'.
                        '<div class="my-rating-2" data-rating="'.($info->{reit}/100).'">'.$buts.
                        '</div>'.$usreit.
                        '</hr></p>
                    </div><h3>'.
                    $info->{year}.'<input type="checkbox" onchange="subm2(this)" name="'.$info->{year}.'"/>&nbsp;&nbsp;&nbsp;'.$info->{coun}.'</h3></p><hr>'
        .'</p>'.$info->{genr}.'</p><hr><H2>'.$info->{runame}.'</p>'.$info->{orname}.'</H2><hr>'.
        'Director:'.$info->{director}.'</p><hr>
        Stars:'.$info->{actor1}.'&nbsp;'.$info->{actor2}.'&nbsp;'.$info->{actor3}.'&nbsp;'.$info->{actor4}.'&nbsp;'.$info->{actor5}.'</p><hr>'
        .$info->{review}.'</p><hr>'.
        $clock.'<hr>'.$rew.$usrew.
        '<div id="weather" style="width: 350px;height: 100px;margin: 8px 10px 10px 10px;float: left;position: relative;top: -10px;">
        <a target="_blank" href="http://nochi.com/weather/kazan-4422">
        <img style="width: 250px" src="https://w.bookcdn.com/weather/picture/1_4422_1_20_babec2_320_ffffff_333333_08488D_1_ffffff_333333_0_6.png?scode=124&domid=589&anc_id=35927"  alt="booked.net"/></a>
        <p><h></div>
        <div class="clock"><div id="Date"></div>
                <ul> <li class="hours"> </li>
                <li class="point">:</li>
                <li class="min"> </li>
                <li class="point">:</li>
                <li class="sec"> </li></ul></div>
                <img src="/images/buttons/logo.png" /></div>';
    }
    $l = '<hr><div class="left_col">'.$lb.$l.'</div>';
    $r = '</div><div id="right_col">'.$rb.$r.'</div>'; 
    return  $l, $full, $r;
}

__PACKAGE__->meta->make_immutable;

1;
