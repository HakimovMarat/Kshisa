package kshisa::Model::Yaml;
use base 'Catalyst::Model::DBIC::Schema';
use Moose;
use utf8;
use namespace::autoclean;
use LWP;
use LWP::Simple qw(getstore);
use YAML::Any qw(LoadFile DumpFile);
use Image::Magick;
use File::Copy;

__PACKAGE__->config(
    schema_class => 'kshisa::Schema',
    connect_info => [
        'dbi:mysql:kshisa',
        'root',
        '63477463',
        {
            AutoCommit        => 1,
            RaiseError        => 1,
            mysql_enable_utf8 => 1,
        },
    ]
);
sub _findpic {
    my ($numb) = @_;
    my $left;
    my $p = $numb/4 - int($numb/4);
    if    ( $p == 0)    { $left = $numb-4}
    elsif ( $p == 0.75) { $left = $numb-3}
    elsif ( $p == 0.5)  { $left = $numb-2}
    elsif ( $p == 0.25) { $left = $numb-1}
    return $left
}
sub user {
    my ($self, $userPath, $name, $avat, $mail) = @_;
    my ($ds) = LoadFile($userPath.0);
    my $count = $ds->{0};
    my ($pass, $info);
    newpass: while (1) {
        my @chars = split( " ","A B C D E F G H" );
        for (0..5) {
            $pass .= $chars[int(rand 8)]
        }
        for (1..$count) {
            if ($pass eq $ds->{$count}{1}) {
                next newpass
            }
        }
        last
    }
    $count++;
    $ds->{$count}{0} = $count;
    $ds->{$count}{1} = $pass;
    $ds->{$count}{2} = $name;
    $ds->{$count}{3} = $mail;
    $ds->{0} = $count;
    DumpFile($userPath.0, $ds);
    my $auth = 100;
    $info->{0}{0} = $name;
    $info->{0}{1} = 'ava000'; #$avat
    $info->{0}{2} = $mail;
    $info->{0}{3} = 1;
    $info->{1}{0}{0} = 1;
    for (1..7) {
        $info->{1}{0}{$_} = 0;
    }
    $info->{1}{0}{3} = 1;
    $info->{1}{0}{7} = 1;
    $info->{1}{1}{0} = $auth;
    $info->{1}{2}{0} = 0;
    $info->{1}{3}{0} = 0;
    my ($ds1) = LoadFile('/home/marat/Base/best');
    for (1..$auth) {
        my $film = $ds1->{$_};
        $info->{1}{1}{$_} = {%$film};
    }
    my $num = 1;
    for my $rs ( 1.. $count-1) {                                          # MAKING FRIENDSFILES
        my $rs1 = $ds->{$rs}{0};
        my ($ds1) = LoadFile($userPath.$rs1);
        $info->{2}{0} = $num;
        $info->{2}{$num} = {
            0 => $rs1,
            1 => $ds1->{0}{0},
            2 => $ds1->{0}{1},
            3 => 'G',
        };
        $num++;
        my $coun = $ds1->{2}{0};
        $ds1->{2}{0} = $coun+1;
        $ds1->{2}{$coun+1} = {
            0 => $ds->{$count}{0},
            1 => $info->{0}{0},
            2 => $info->{0}{1},
            3 => 'G',
        };
        DumpFile($userPath.$rs1, $ds1);    
    }
    DumpFile($userPath.$count, $info);
    return $pass
}

sub prewiew {
    my ($self, $userPath, $img_path2, $cols, $param) = @_;
    my (%cols, $path, $info);
    my $temp = LoadFile($userPath.'temp');
    my $code = $temp->{'code'};
    my $n = 1;
    foreach my $key (sort keys %$param) {                               # NUMBER OF PICS
        if ($key =~ /^(\d+)$/) {
            $temp->{'k'.$n} = $1;
            $path->[$n] = '" src="/images/find1/'.$1;
            $n++;
        }
    }
    getstore($temp->{'kad0'}, $img_path2.$code.'kad0.jpg');
    $path->[0] = '" src="/images/find/'.$code.'kad0';
    
    my $image = Image::Magick->new;	
    $image->Read($img_path2.$code.'kad0.jpg');
    $image->Resize(width=>320, height=>455);
    $image->Write($img_path2.$code.'kad0.jpg');
    
    my $image1 = Image::Magick->new;
    $image1->Read($img_path2.$code.'kad0.jpg');
    $image1->Quantize(colorspace=>'gray');
    $image1->Write($img_path2.$code.'kad0G.jpg');
    
    DumpFile($userPath.'temp', $temp);
    $info->{$_->[0]} = $temp->{$_->[0]} foreach @{$cols};
    my $p = '<img class="post'.$path->[0].'.jpg"/>';                           # POSTER
    my $k = '<img class="kadr'.$path->[1].'.jpg"/>'.                           # FRAMES
            '<img class="kadr'.$path->[2].'.jpg"/>'. 
            '<img class="kadr'.$path->[3].'.jpg"/>'. 
            '<img class="kadr'.$path->[4].'.jpg"/>';
    my $full = $p.'<div class="foto">'.$k.'<hr></div>';
    return $full
}
sub tempOut {
    my ($self, $cols, $userPath) = @_;
    my %cols;
    my $path = $userPath.'temp';
    my $ds = LoadFile($path);
    $cols{$_} = $ds->{$_} foreach (@$cols);
    return \%cols
}
sub find {
    my ($self, $name, $dsl) = @_;
    $name =~ s/^\s*//;
    $name =~ s/ё/е/g;
    my $find = 0;
    my ($runame, $orname, $file, $cout, $side, $info, $left);
    for (1..$dsl->{1}{1}{0}) {
        $runame = lc $dsl->{1}{1}{$_}{'runame'};
        $orname = lc $dsl->{1}{1}{$_}{'orname'};
        if (lc $name eq $runame or lc $name eq $orname) {
            ($file, $cout, $side, $info) = (1, $_,  0, $dsl->{1}{1}{$_});
            $left = _findpic($_);
            $find = 1;
            last;
        }
    }

return $find, $file, $cout, $side, $info, $left,   
}
sub rew {
    my ($self, $ds, $cout, $param, $love) = @_;
    my $n;
    $n = 2 if $love == 0;
    $n = 4 if $love == 1;
    my $count = $ds->{1}{$n}{$cout}{0} + 1;
    $ds->{1}{$n}{$cout}{0} = $count;
    $ds->{1}{$n}{$cout}{'usreit'} = $param->{usreit}.'00';
    
    $ds->{1}{$n}{$cout}{$count}{'time'} = localtime();
    $ds->{1}{$n}{$cout}{$count}{'rewi'} = $param->{rew};
    $ds->{1}{$n}{$cout}{'grey'} = '';
    $ds->{0}{'reit'} = $ds->{0}{'reit'} + 1;
    
    my $usreit = 'Yours:'.$ds->{1}{$n}{$cout}{'usreit'};
    my $usrew = $ds->{1}{$n}{$cout}{$count}{'rewi'};

    return $usreit, $usrew
}
sub step {
    my ($self, $param, $next, $count) = @_;
    if    ( $param->{'Next_l.x'} or $param->{'Next_r.x'} ) {
        $next = $next + 4;
        $next = 0             if $next > ($count-$count%3);
    }
    elsif ( $param->{'Last_l.x'} or $param->{'Last_r.x'} ) {
        $next = $next - 4;
        $next = ($count-$count%4)            if $next < 0;
    }
    return $next
}
sub base {
    my ( $self, $selec, $userPath) = @_;
    my ($ds) = LoadFile($userPath.'all');
    my $max = $ds->{1}{1}{0};
    my $info;
    $info->{1}{0} = $max;
    for ( 1..$max ) {
        $info->{1}{2}{$_} = $ds->{1}{1}{$_}{'code'};
    }
    for ( 1..$max ) {
        $info->{1}{1}{$ds->{1}{1}{$_}{'code'}} = {
            year      => $ds->{1}{1}{$_}{'year'},
            coun      => $ds->{1}{1}{$_}{'coun'},
            code      => $ds->{1}{1}{$_}{'code'},
            genr      => $ds->{1}{1}{$_}{'genr'},
            time      => $ds->{1}{1}{$_}{'time'},
            reit      => $ds->{1}{1}{$_}{'reit'},
            runame    => $ds->{1}{1}{$_}{'runame'},
            orname    => $ds->{1}{1}{$_}{'orname'},
            director  => $ds->{1}{1}{$_}{'director'},
            actor1    => $ds->{1}{1}{$_}{'actor1'},
            actor2    => $ds->{1}{1}{$_}{'actor2'},
            actor3    => $ds->{1}{1}{$_}{'actor3'},
            actor4    => $ds->{1}{1}{$_}{'actor4'},
            actor5    => $ds->{1}{1}{$_}{'actor5'},
            review    => $ds->{1}{1}{$_}{'review'},

        };
    }

    DumpFile($userPath.'base', $info);
    chmod 0666, $userPath.'base';
}
sub mashine {
    my ($self, $ds, $cout, $dsl, $userPath, $mode) = @_;

    my ($dsb) = LoadFile($userPath.'base');
    my $new = $dsl->{1}{1}{$cout};

    my ( @dna, @dna1, @dna2, %dna, @seen, @tosee, @tosee0, @code );
    my ( $dna4, $dna5 ) = ( 'a0a0', '9999' );

    push @dna, substr ($ds->{1}{1}{$cout}{'code'}, 4*$_, 4) for (1..3); # DNA
    if ($ds->{0}{'DNA1'}) {                                             
        push @dna1, split ':', $ds->{0}{'DNA1'};
        push @dna2, split ':', $ds->{0}{'DNA2'};
        $dna{$dna1[$_]} = $dna2[$_] for (1..@dna1-1);
        foreach my $four1 (0..2) {
            foreach my $four2 (keys %dna){
                if ($dna[$four1] eq $four2 ){
                    $dna{$four2} = $dna{$four2} + 1;
                    $dna[$four1] = undef
                } 
            }
        }           
        for ( @dna ) {
            $dna{$_} = 1001 if($_);
        }
        foreach (sort {$dna{$b}<=>$dna{$a}} keys %dna){
            $dna4 = $dna4.':'.$_;
            $dna5 = $dna5.':'.$dna{$_};
        }
        $ds->{0}{'DNA1'} = $dna4;
        $ds->{0}{'DNA2'} = $dna5;
    } 
    else {
        $ds->{0}{'DNA1'} = 'a0a0:'.$dna[0].':'.$dna[1].':'.$dna[2];
        $ds->{0}{'DNA2'} = '9999:1001:1001:1001';
        $dna{$dna[$_]} = '1001' for 0..2;
    }
        
    if ($ds == $dsl) {
        push @seen, $ds->{1}{1}{$_}{'code'} for (1..$ds->{1}{1}{0});
        push @seen, $ds->{1}{2}{$_}{'code'} for (1..$ds->{1}{2}{0});
        push @seen, $ds->{1}{3}{$_}         for (1..$ds->{1}{3}{0});
        push @seen, $ds->{1}{4}{$_}{'code'} for (1..$ds->{1}{4}{0});
        
        push @tosee0, $dsb->{1}{2}{$_} for (1..$dsb->{1}{0});
        foreach my $tosee (@tosee0) {
            my $equal = 0;
            foreach my $seen (@seen) {
                if ($tosee eq $seen){
                    $equal = 1;
                }
            }
            push @tosee, $tosee if $equal == 0;
        }
        my (%ureit1, $winer);
        $ureit1{$_} = 0 for (@tosee);
        foreach my $tosee (@tosee) {                                    # REITS
            my @parts;
            for (1..3) {
                push @parts, substr $tosee, $_*4, 4;
            }
            foreach my $part (@parts) {
                while ( my ( $dna1, $dna2 ) = each %dna ) {
                    $ureit1{$tosee} = $ureit1{$tosee} + $dna2 if ($part eq $dna1)
                }
            }
        }
        foreach (sort {$ureit1{$b}<=>$ureit1{$a}} keys %ureit1) {
            $ureit1{$_} = $ureit1{$_} + $dsb->{1}{1}{$_}{'reit'};
            last if %ureit1 eq 4;
        }
        foreach (sort {$ureit1{$b}<=>$ureit1{$a}} keys %ureit1) {
            $winer = $_;
            last;
        }
        my $num = 1;
        my $dsc;
        $dsc->{0}{0} = $winer;
        $dsc->{0}{1} = $ureit1{$winer};
        $dsc->{0}{2} = $dsb->{1}{1}{$winer}{'runame'};    
        for (@tosee) {
            $dsc->{1}{$num}{0} = $ureit1{$_};
            $dsc->{1}{$num}{1} = $dsb->{1}{1}{$_}{'reit'};
            $dsc->{1}{$num}{2} = $_;
            $dsc->{1}{$num}{3} = $dsb->{1}{1}{$_}{'runame'};
            $dsc->{1}{$num}{4} = 'WWWWWWWWWWWWWWWWWWWWWWWW' if $dsc->{1}{$num}{2} eq $winer;
            $num++;
        }
        delete $ds->{1}{1}{$cout};
        $ds->{1}{1}{$cout} = $dsb->{1}{1}{$winer};
        DumpFile($userPath.'code', $dsc);
    }
    if ($mode eq 'g') {                                                 # THE CHOICE FOR VIEWING
        my $count = $ds->{1}{2}{0}+1;                                   # USER FOR VIEWING CHOICE COUNTER
        $ds->{1}{2}{0} = $count;
        $ds->{1}{2}{$count} = {%$new};                                      
        $ds->{1}{2}{$count}{'grey'} = 'G';
        my $right = _findpic($count);
        return $count, $right
    }
    if ($mode eq 'h') {                                                 # THE CHOICE OF FAVORITE
        my $count = $ds->{1}{4}{0}+1;                                   # USER FAVORITE CHOICE COUNTER
        $ds->{1}{4}{0} = $count;
        $ds->{1}{4}{$count} = {%$new};                                      
        $ds->{1}{4}{$count}{'grey'} = 'G';
        my $right = _findpic($count);
        return $count, $right
    }
     
}
sub del {
    my ( $self, $ds, $dsl, $cent, $maxr, $love ) = @_;
    my ($side, $info, $left, $mess);
    my $count = $ds->{1}{3}{0} + 1;
    $ds->{1}{3}{$count} = $ds->{1}{$love}{$cent}{'code'};
    $ds->{1}{3}{0} = $count;
    
    delete $ds->{1}{$love}{$cent};
    $ds->{1}{$love}{0} = $maxr-1;
    if ($ds->{1}{$love}{0}== 0) {
        ($side, $cent, $left) = (0, 1, 0);
        $info = $dsl->{1}{1}{$cent};
    }
    else {
        $side = 1;
        my $n = 1;
        while ($ds->{1}{$love}{$cent + $n}) {
            my $next = $ds->{1}{$love}{$cent+$n};
            $ds->{1}{$love}{$cent+$n-1} = {%$next};
            delete $ds->{1}{$love}{$cent+$n};
            $n++;
        }
        if ($cent > 1) {
            $cent = $cent-1;
        }
        else {
            $cent = $cent;
        }
        $info = $ds->{1}{$love}{$cent};
    }
    return $cent, $side, $info, $left
}
sub numb {
    my ($self, $Info, $dsl) = @_;
    my ($message, $cout, $side, $info, $left);
        if ($Info) {
            if ($Info <= $dsl->{1}{1}{0}) {
                ($cout, $side, $info, $left) = ($Info,  0, $dsl->{1}{1}{$Info}, _findpic($Info));
                
            }    
            else {
                my $max = $dsl->{1}{1}{0};
                ($cout, $side, $info, $left) = ($max, 0, $dsl->{1}{1}{$max}, _findpic($max));
                $message = 'exceeded maximum-'.$max;
            }
        }
        else {
            ($cout, $side, $info, $left) = (1, 0, $dsl->{1}{1}{1}, 0);
            $message = 'type number';
        }
    return $message, $cout, $side, $info, $left
}
sub dump {
    my ( $self, $userPath, $id, $ds, $file, $left, $side, $right, $cout, $love ) = @_;
  
    if ($file == 0) {
        $ds->{1}{0}{2} = $left;                                         # LEFT PICS VAR
        $ds->{1}{0}{3} = $cout if $side == 0;
    }
    if ($file == 1) {
        $ds->{1}{0}{6} = $left;                                         # LEFT PICS VAR
        $ds->{1}{0}{7} = $cout if $side == 0;
    }
    if ($love == 0) {
        $ds->{1}{0}{4} = $right;                                        # RIGHT PICS VAR
        $ds->{1}{0}{5} = $cout if $side == 1;
    }
    if ($love == 1) {
        $ds->{1}{0}{8} = $right;                                        # RIGHT PICS VAR
        $ds->{1}{0}{9} = $cout if $side == 1;
    }
    ($ds->{1}{0}{0}, $ds->{1}{0}{1}, $ds->{1}{0}{10}) = ($file, $side, $love);

    DumpFile($userPath.$id, $ds);                                       # DUMP INFO IN USERFIle
}
sub crew {
    my ($self, $img_path, $userPath) = @_;
    my (@pics, $micro);
    my $ds = LoadFile($userPath.'temp');
    my $act0 = $ds->{'director'};
    my $ua = LWP::UserAgent->new;
    my $address = 'https://afisha.mail.ru/search/?region_id=42&q='.$act0;
    my $req = HTTP::Request->new( 'GET', $address);
    $req->header('User-Agent' => 'Opera/9.80 (X11; Linux i686) Presto/2.12.388 Version/12.16');
    $req->header('Accept-Language' => 'ru,en;q=0.9');
    $req->header('Accept-Encoding' => 'gzip, deflate');
    my $resp = $ua->request($req);
    my $content = $resp->decoded_content;
}
sub mail {
    my ($self, $find, $img_path3, $userPath, $cols) = @_;
    my (@film0, @film1, @entries);
    if ($find =~ /^(\d+_.*?)\.x/) {
        $find =~ tr[.x][]d;
    }
    else {
        unlink glob "$img_path3*.*";
        my $ua = LWP::UserAgent->new;
        my $address = 'https://afisha.mail.ru/search/?region_id=42&q='.$find;
        my $req = HTTP::Request->new( 'GET', $address);
        $req->header('User-Agent' => 'Opera/9.80 (X11; Linux i686) Presto/2.12.388 Version/12.16');
        $req->header('Accept-Language' => 'ru,en;q=0.9');
        $req->header('Accept-Encoding' => 'gzip, deflate');
        my $resp = $ua->request($req);
        my $content = $resp->decoded_content;
        
        for ($content) {
            while ( $_ =~ m{/(\d+)/.*?movies/(.*?)/.*?}mg) {
               push @film0, $1;
               push @film1, $2;
            }
        }
        $find = $film1[0];
        for ( 0..4 ) {
            my $dir = $img_path3.$film1[$_].'.jpg';
            getstore( 'https://pic.afisha.mail.ru/'.$film0[$_].'/', $dir );
        }
   }
    my $address = 'https://afisha.mail.ru/cinema/movies/'.$find;
    my $browser = LWP::UserAgent->new;
    my $response = $browser->get( $address, 
    'User-Agent'      => 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0', 
    'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3');
    my $cont= $response->decoded_content;

    my $filename = '/home/marat/mail.html';
    open my $fh, '>', $filename;
    print $fh $cont; 
    my (%cols1, $am, @pics, @country, @genre, $orname, $rew, $line);
    
    for ($cont) {
        $cols1{'runame'} = $1 if ( $_ =~ m{font-weight: 700;">(.*?)</h1>});
        if ( $_ =~ m{alternativeHeadline">(.*?)</h2></div>} ) {
            $orname = $1;
            #$orname =~ s[&#183;][-]d;
            #$orname =~ s[&#39;][']d;
            $cols1{'orname'} = $orname;
        }
        if ( $_ =~ m{<span class="margin_left_10">(.*?)</span>} ) {
            my $reit = $1;
            $reit =~ tr[.][]d;
            $reit = $reit.0;
            $cols1{'reit'} = $reit;
        }
        $cols1{'year'} = $1 if ( $_ =~ m{href="/cinema/all/.*?/"><span class="link__text">(.*?)</span></a></span><span } );
        $cols1{'time'} = $1*60+$2 if ( $_ =~ m{duration" content="(.*?):(.*?)"/>} );
        $cols1{'director'} = $2 if ( $_ =~ m{director" href="(.*?)"><span.*?>(.*?)<} );
        $cols1{'No'} = $find;
        if ( $_ =~ m{description"><p>(.*?)<} ) {
            $rew = $1;
            $rew =~ tr[&nbsp;][ ]d;
            $rew =~ tr[&mdash;]["—]d;
            $rew =~ tr[&hellip;]["..."]d;
            #$rew =~ s[ rquo]["]d;
            #$rew =~ s[.quo]["]d;
            $cols1{'review'} = $rew;
        }
        
        if ( $_ =~ m{(ne" href="/c.*?text">(.*?)<)(.*?ne" href="/c.*?text">(.*?)<)?(.*?ne" href="/c.*?text">(.*?)<)?(.*?ne" href="/c.*?text">(.*?)<)?} ) {
            $cols1{'coun_0'} = $2 if $2;
            $cols1{'coun_1'} = $4 if $4;
            $cols1{'coun_2'} = $6 if $6;
            $cols1{'coun_3'} = $8 if $8;
        }
        if ( $_ =~ m{(badge_link.*?<span class="badge__text">(.*?)<)(.*?badge_link.*?<span class="badge__text">(.*?)<)?(.*?badge_link.*?<span class="badge__text">(.*?)<)?(.*?badge_link.*?<span class="badge__text">(.*?)<)?} ) {
            $cols1{'genr_0'}  = $2 if $2;
            $cols1{'genr_1'}  = $4 if $4;
            $cols1{'genr_2'}  = $6 if $6;
            $cols1{'genr_3'}  = $8 if $8;
        } 
        if ( $_ =~ m{(actor" href="(.*?)"><span.*?>(.*?)<)(.*?actor" href="(.*?)"><span.*?>(.*?)<)?(.*?actor" href="(.*?)"><span.*?>(.*?)<)?(.*?actor" href="(.*?)"><span.*?>(.*?)<)?(.*?actor" href="(.*?)"><span.*?>(.*?)<)?(.*?actor" href="(.*?)"><span.*?>(.*?)<)?} ) {
            $cols1{'actor1'} = $3;
            $cols1{'actor2'} = $6;
            $cols1{'actor3'} = $9;
            $cols1{'actor4'} = $12;
            $cols1{'actor5'} = $15;
        }
        $cols1{'kad0'} = $1 if ( $_ =~ m{Toggle.*?src="(.*?)" alt=""} );
        $cols1{'size'} = $am = $1 if ( $_ =~ m{Кадры.*?ing">(\d+)<} );
        my $n = 1;
        for my $p ( 1..$am*2+4 ) {
            my $pice = $1 if ($_ =~ m{(https:\/\/pic.kino.mail.ru\/\d+\/)}g);
            if ($p > 4 && $p%2 != 0) {
                $cols1{'kad'.$n} = $pice;
                $n++;
            }
        }
    }
    my $info = {%cols1};
    delete $cols1{'kad0'};
    
    my $ds = LoadFile($userPath.'all');
    my %cols0;
    for my $numb (1.. $ds->{1}{1}{0}) {
        if ($ds->{1}{1}{$numb}{'orname'} eq $info->{'orname'} && $ds->{1}{1}{$numb}{'year'} eq $info->{'year'}) {
            $info->{numb} = $numb;
            $info->{code} = $ds->{1}{1}{$numb}{'code'};
            foreach (@$cols) {
                if ($_ =~ /(\D+)_(\d+)/) {
                    my @set = split ' ', $ds->{1}{1}{$numb}{$1};
                    $cols0{$_} = $set[$2];
                }
                else {
                    $cols0{$_} = $ds->{1}{1}{$numb}{$_}
                }
            }
        }
    }
    DumpFile($userPath.'temp', $info);
    my $left;
    my $rigt;
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image" name="'.$film1[$_].'.jpg" src="/images/find/'.$film1[$_].'.jpg">' if $film1[$_];
    }
    for ( 0..4 ) {
        $rigt = $rigt.'<img class="image1" name="'.$_.'" src="/images/imgs/'.$info->{code}.'kad'.$_.'.jpg" />';
    }
    return $left, $rigt, \%cols1, \%cols0, 

}
sub start {
    my ($self, $img_path3, $userPath, $cols, $numb) = @_;
    my ($left, $rigt, %cols0, @set);
    opendir (my $dh, $img_path3) || die "can't opendir $img_path3: $!";;
    my @files = grep { !/^\./ } readdir($dh);
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image" name="'.$files[$_].'" src="/images/find/'.$files[$_].'">' if $files[$_];
    }
    my $ds = LoadFile($userPath.'all');
    $numb = 1 if $numb > $ds->{1}{1}{0};
    $numb = $ds->{1}{1}{0} if $numb < 1;    
    for ( 0..4 ) {
        $rigt = $rigt.'<img class="image1" name="'.$_.'" src="/images/imgs/'.$ds->{1}{1}{$numb}{code}.'kad'.$_.'.jpg" />';
    }
    foreach (@$cols) {
        if ($_ =~ /(\D+)_(\d+)/) {
            @set = split ' ', $ds->{1}{1}{$numb}{$1};
            $cols0{$_} = $set[$2];
        }
        else {
            $cols0{$_} = $ds->{1}{1}{$numb}{$_}
        }
    }
    return $left, $rigt, \%cols0, $numb
}
sub cret {
    my ($self, $cols, $userPath, $select, $cols1, $img_path3) = @_;
    my $ds = LoadFile($userPath.'all');
    my $temp = LoadFile($userPath.'temp');
    my $numb = $ds->{1}{1}{0};
    my $numb1 = $temp->{numb};
    my %cols;
    my $code = substr lc $cols1->{'orname'}, 0, 4;                      # FILM CODE
    $code = substr lc $cols1->{'orname'}, 4,  4  if ($cols1->{'orname'} =~ /^The/);
    $code =~ tr[ ][_];
    
    my (@coun, @genr);
    my %count1;
    my %country = %{$select->{'coun'}};
    foreach (keys %country) {
        $count1{$country{$_}[1]} = $_; 
    }
    my %genre1;
    my %genre = %{$select->{'genr'}};
    foreach (keys %genre) {
        $genre1{$genre{$_}[1]} = $_; 
    }
    my $coun = $count1{$cols1->{'coun_0'}};
    my $genr = $genre1{$cols1->{'genr_0'}};
  
    $cols{'code'} = $code.$cols1->{'year'}.lc$coun.lc$genr;
    $temp->{code} = $cols{'code'};
    $cols{'coun'} = $cols1->{'coun_0'}.' '.$cols1->{'coun_1'}.' '.$cols1->{'coun_2'}.' '.$cols1->{'coun_3'};
    $cols{'genr'} = $cols1->{'genr_0'}.' '.$cols1->{'genr_1'}.' '.$cols1->{'genr_2'}.' '.$cols1->{'genr_3'};
    $cols{'year'} = $cols1->{'year'};
    $cols{'time'} = $cols1->{'time'};
    $cols{'reit'} = $cols1->{'reit'};
    $cols{'runame'} = $cols1->{'runame'};
    $cols{'orname'} = $cols1->{'orname'}; 
    $cols{'director'} = $cols1->{'director'};                          
    $cols{'actor1'} = $cols1->{'actor1'};
    $cols{'actor2'} = $cols1->{'actor2'};
    $cols{'actor3'} = $cols1->{'actor3'};
    $cols{'actor4'} = $cols1->{'actor4'};
    $cols{'actor5'} = $cols1->{'actor5'};
    $cols{'magnet'} = $cols1->{'magnet1'};
    $cols{'review'} = $cols1->{'review'};       
    if ($numb1) {
        $ds->{1}{1}{$numb1} = {%cols};
    }
    else {
        $numb++;
        $ds->{1}{1}{$numb} = {%cols};
    }
    my (@info, $info);                                                  # SORT BY YEAR AND REIT
    for (1..$numb) {
        push @info, {
            numb=>$_,
            code=>$ds->{1}{1}{$_}{'code'},
            year=>$ds->{1}{1}{$_}{'year'}, 
            reit=>$ds->{1}{1}{$_}{'reit'},
            }
    }
    @info = sort {
        $b->{year} <=> $a->{year}
        ||
        $b->{reit} <=> $a->{reit}
    } @info;
    $info->{1}{1}{0} = $numb;
    for (1..$numb) {
        my $n = $info[$_-1]->{numb};
        $info->{1}{1}{$_} = $ds->{1}{1}{$n};
        if ($info->{1}{1}{$_}{'code'} eq $cols{'code'}) {
            $temp->{numb} = $_;
        }
    }
    DumpFile($userPath.'all', $info);
    DumpFile($userPath.'temp', $temp);
    my ($left, $rigt);
    opendir (my $dh, $img_path3) || die "can't opendir $img_path3: $!";;
    my @files = grep { !/^\./ } readdir($dh);
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image" name="'.$files[$_].'" src="/images/find/'.$files[$_].'">' if $files[$_];
    }
        for ( 0..4 ) {
        $rigt = $rigt.'<img class="image1" name="'.$_.'" src="/images/imgs/'.$info->{code}.'kad'.$_.'.jpg" />';
    }
    return $left, $rigt
}
sub pics {
    my ($self, $img_path, $userPath, $img_path3) = @_;
    unlink glob "$img_path*.*";
    my (@pics, $micro);
    my $ds = LoadFile($userPath.'temp');
    for (1..$ds->{'size'}) {
        push @pics, $ds->{'kad'.$_};
    }
    getstore($pics[$_], $img_path.$_.'.jpg') for 0..$#pics;
    for ( 0..$#pics ) {
        my $image = Image::Magick->new;
        my $dir = $img_path.$_.'.jpg';
        $image->Read($dir);
        $image->Resize(geometry => '330x210');
        $image->Crop(width=>272, height=>178);
        $image->Write($img_path.$_.'.jpg');
    }
    for ( 1..$#pics ) {
        $micro = $micro.'<img name="'.$_.'" src="/images/find1/'.$_.'.jpg" /><input type="checkbox" name="'.$_.'" />';
    }
    $micro = '<hr><div id="pics">'.$micro.'<input type="submit" name="find3" value="3" style="width: 40px;" /></div>';
    my $left;
    opendir (my $dh, $img_path3) || die "can't opendir $img_path3: $!";;
    my @files = grep { !/^\./ } readdir($dh);
    for ( 0..6 ) {
        $left = $left.'<div class="numb">'.($_+1).'</div><input type="image" class="image" name="'.$files[$_].'" src="/images/find/'.$files[$_].'">' if $files[$_];
    }
    return $micro, $left
}
sub imgs {
    my ($self, $userPath, $img_path1, $img_path2, $img_path3, $img_path4) = @_;

    my $temp = LoadFile($userPath.'temp');
    my $code = $temp->{'code'};
    for my $n (0..4) {
        unlink $img_path2.$temp->{'code'}.'kad'.$n.'.jpg'
    }
    unlink $img_path2.$temp->{'code'}.'kad0G.jpg';
    for (1..4) {
        copy ($img_path1.$temp->{'k'.$_}.'.jpg', $img_path2.$code.'kad'.$_.'.jpg');
        copy ($img_path1.$temp->{'k'.$_}.'.jpg', $img_path4.$code.'kad'.$_.'.jpg');
    }
    copy ($img_path3.$temp->{'code'}.'kad0.jpg', $img_path2.$code.'kad0.jpg');
    copy ($img_path3.$temp->{'code'}.'kad0G.jpg', $img_path2.$code.'kad0G.jpg');
    copy ($img_path3.$temp->{'code'}.'kad0.jpg', $img_path4.$code.'kad0.jpg');
    copy ($img_path3.$temp->{'code'}.'kad0G.jpg', $img_path4.$code.'kad0G.jpg');
    unlink $img_path3.$temp->{'code'}.'kad0.jpg';
    unlink $img_path3.$temp->{'code'}.'kad0G.jpg';
    my $rigt;
    for ( 0..4 ) {
        $rigt = $rigt.'<img class="image1" name="'.$_.'" src="/images/imgs/'.$temp->{'code'}.'kad'.$_.'.jpg" />';
    }
    return $temp->{'numb'}, $rigt
}
sub mysql {                                                             # FROM YAML TO MYSQL
    my ($self, $cols, $select, $userPath) = @_;
    my (@cols, %cols);
    push @cols, $_->[0] foreach @{$cols};                               # NAMES OF FIELDS

    my $ds = LoadFile($userPath.'all');
    
    my %country1;
    my %country = %{$select->{'coun'}};
    foreach my $country (keys %country) {
        $country1{$country{$country}[1]} = $country; 
    }
    my %genre1;
    my %genre = %{$select->{'genr'}};
    foreach my $genre (keys %genre) {
        $genre1{$genre{$genre}[1]} = $genre; 
    }
    for (1..$ds->{1}{1}{0}) {
        for my $n (0..12) {
            $cols{$cols[$n]} = $ds->{1}{1}{$_}{$cols[$n]};
        } 
        $cols{'magnet1'} = $ds->{1}{1}{$_}{'magnet'};
        my (@coun, @genr);
        push @coun, split (/ /, $ds->{1}{1}{$_}{'coun'});
        push @genr, split (/ /, $ds->{1}{1}{$_}{'genr'});
        $cols{'coun'} = $country1{$coun[0]}.':'.$country1{$coun[1]}.':'.$country1{$coun[2]}.':'.$country1{$coun[3]};
        $cols{'genr'} = $genre1{$genr[0]}.':'.$genre1{$genr[1]}.':'.$genre1{$genr[2]}.':'.$genre1{$genr[3]};
        $self->resultset('Films2')->update_or_create({ %cols });
       
    }
}

=head1 NAME
kshisa::Model::Yaml - Catalyst Model
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
