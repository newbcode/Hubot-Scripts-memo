package Hubot::Scripts::memo;

use strict;
use warnings;
use Data::Printer;
use DateTime;
use AnyEvent::DateTime::Cron;
use RedisDB;

my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'Asia/Seoul');
my $redis = RedisDB->new(host => 'localhost', port => 6379);

sub load {
    my ( $class, $robot ) = @_;
 
    $robot->hear(
            qr/^memo (.+)/i,

            sub {
                my $msg = shift;

                my $user = $msg->message->user->{name};
                my $user_memo = $msg->match->[0];
                my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                print $dt->ymd;

=pod
                $robot->brain->{data}{memo}{$user}{ +time } = 
                    [ $user, $user_memo, $dt->ymd . " " . $dt->hms ];
                $msg->send("$user_memo". "  $user");
                $msg->send($robot->brain->{data}{memo}{$user}{ +time}->[1]. "  $user");
=cut
                
            }
    );
}
1;

=pod

=head1 Name 

    Hubot::Scripts::memo
 
=head1 SYNOPSIS

    naver perl cafe (new issue) monitoring.
    perlstudy on - naver cafe(perlstudy) to start monitoring.
    perlstudy off|finsh - naver cafe(perlstudy) to stop monitoring.
    perlstudy status - naver cafe(perlstudy) status.
 
=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
