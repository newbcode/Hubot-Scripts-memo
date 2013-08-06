package Hubot::Scripts::memo;

use 5.010;
use strict;
use warnings;
use utf8;
use Data::Printer;
use DateTime;
use AnyEvent::DateTime::Cron;
use RedisDB;

my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'Asia/Seoul');
my $redis = RedisDB->new(host => 'localhost', port => 6379);
my $gm_msg = 'Good Moring Perlmongers!';

sub load {
    my ( $class, $robot ) = @_;
    
    my $flag = 'off';
    my $memo_time;

    $robot->hear(
        qr/^memo (.*?) (.+)/i,

        sub {
            my $msg = shift;

            my $jotter = $msg->message->user->{name};
            my $reserv_time = $msg->match->[0];
            my $user_memo = $msg->match->[1];

            my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
            my $ymd = $dt->ymd;
            my $year = $dt->year;
            my $month = $dt->month;
            my $day = $dt->day;
            my $hour = $dt->hour;
            my $min = $dt->minute;

            if ( $month < 10 ) { $month = "0"."$month"; }
            if ( $day < 10 ) { $day = "0"."$day"; }
            if ( $hour < 10 ) { $hour = "0"."$hour"; }
            if ( $min < 10 ) { $min = "0"."$min"; }

            given ($reserv_time) {
                when ( /^\d\d\d\d\-\d\d\-\d\d\-\d\d:\d\d$/ ) { 
                    $memo_time = $reserv_time }
                when ( /^\d\d\-\d\d\-\d\d:\d\d$/ ) { 
                    $memo_time = "$year"."-$reserv_time" }
                when ( /^\d\d\:\d\d$/ ) { 
                    $memo_time = "$year"."-$month"."-$day"."-$reserv_time" }
                default { $msg->send( "Time format is wrong!") }
            }

            $redis->hmset("$memo_time", 'content', "$user_memo", 'jotter', "$jotter");
            if ( $memo_time ) { $msg->send('Save Memo has been completed') };

            my $show_memo = $redis->hmget("$memo_time", 'content', 'jotter');
            $redis->bgsave;
        }
    );

    $robot->hear(
        qr/^memo:? on *$/i,

            sub {
                    my $msg = shift;
            
                    $msg->send('It has been started memo tracking ...');

                    $cron->add( '*/1 * * * *'  => sub {
                        my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                        my $ymd = $dt->ymd;
                        my $year = $dt->year;
                        my $month = $dt->month;
                        my $day = $dt->day;
                        my $hour = $dt->hour;
                        my $min = $dt->minute;

                        if ( $month < 10 ) { $month = "0"."$month"; }
                        if ( $day < 10 ) { $day = "0"."$day"; }
                        if ( $hour < 10 ) { $hour = "0"."$hour"; }
                        if ( $min < 10 ) { $min = "0"."$min"; }

                        my $now_time = "$ymd".'-'."$hour".':'."$min";

                        $msg->send('system time'."  $now_time");
                        $msg->send('memo_time'."   $memo_time");

                        if ( $now_time eq $memo_time ) {
                            my $show_memo = $redis->hmget("$memo_time", 'content', 'jotter');
                            $msg->send($show_memo->[0]);
                            $msg->send($show_memo->[1]);
                        }
                    }
                );
                $cron->start;
                $flag = 'on';
            }
    );

    $robot->hear(
        qr/^memo:? status *$/i,    

            sub {
                my $msg = shift;
                $msg->send("memo status is [$flag] ...");
            }
    );
}
1;

=pod

=head1 Name 

    Hubot::Scripts::memo
 
=head1 SYNOPSIS

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
