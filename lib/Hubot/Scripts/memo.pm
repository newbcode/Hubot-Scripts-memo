package Hubot::Scripts::memo;

use 5.010;
use utf8;
use strict;
use warnings;
use Encode qw(encode decode);
use Data::Printer;
use DateTime;
use AnyEvent::DateTime::Cron;
use RedisDB;
use Text::ASCIITable;

sub load {
    my ( $class, $robot ) = @_;
    
    my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'Asia/Seoul');
    my $redis = RedisDB->new(host => 'localhost', port => 6379);
    my $flag = 'off';
    my $memo_time;
    my $jotter;

    $robot->hear(
        qr/^memo (.*?) (.+)/i,

        sub {
            my $msg = shift;

            $jotter = $msg->message->user->{name};
            my $reserv_time = $msg->match->[0];
            my $user_memo = $msg->match->[1];

            my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
            my ($ymd, $year, $month, $day, $hour, $min ) = ($dt->ymd, $dt->year, $dt->month, $dt->day, $dt->hour, $dt->min);

            if ( $month < 10 ) { $month = "0"."$month"; }
            if ( $day < 10 ) { $day = "0"."$day"; }
            if ( $hour < 10 ) { $hour = "0"."$hour"; }
            if ( $min < 10 ) { $min = "0"."$min"; }

            given ($reserv_time) {
                when ( /^\d\d\d\d\-\d\d\-\d\d\-\d\d:\d\d$/ ) { $memo_time = $reserv_time }
                when ( /^\d\d\-\d\d\-\d\d:\d\d$/ ) { $memo_time = "$year"."-$reserv_time" }
                when ( /^\d\d\:\d\d$/ ) { $memo_time = "$year"."-$month"."-$day"."-$reserv_time" }
                default { $memo_time = 'wrong' }
            }

            if ( $memo_time eq 'wrong' ) { 
                $msg->send( "Time format is wrong!");
            }
            else {
                $redis->hmset("memo_log", "$memo_time", "$user_memo");
                $msg->send('Save Memo has been completed!');
            }
            $redis->bgsave;
        }
    );

    $robot->hear(
        qr/^memo:? on *$/i,

            sub {
                    my $msg = shift;
            
                    my $gm_msg = 'Good moring Seoul.pm !';
                    my $ga_msg = '다들 맛점 하세욤 ♥';
                    my $gn_msg = 'ComeBack Home Hurry Up !!!';

                    $msg->send('It has been started memobot viewer ...');

                    $cron->add( '*/1 * * * *'  => sub {
                        my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                        my ($ymd, $year, $month, $day, $hour, $min ) = ($dt->ymd, $dt->year, $dt->month, $dt->day, $dt->hour, $dt->min);

                        if ( $month < 10 ) { $month = "0"."$month"; }
                        if ( $day < 10 ) { $day = "0"."$day"; }
                        if ( $hour < 10 ) { $hour = "0"."$hour"; }
                        if ( $min < 10 ) { $min = "0"."$min"; }

                        my $now_time = "$ymd".'-'."$hour".':'."$min";
                        my $memo_ref = $redis->hkeys("memo_log");
                        my @memo_keys = @${memo_ref};

                        given ($now_time) {
                        when ( /^\d\d\d\d\-\d\d\-\d\d\-09:00$/ ) { $msg->send("$gm_msg"); }
                        when ( /^\d\d\d\d\-\d\d\-\d\d\-12:00$/ ) { $msg->send("$ga_msg"); }
                        when ( /^\d\d\d\d\-\d\d\-\d\d\-18:00$/ ) { $msg->send("$gn_msg"); }
                        default { $memo_time = 'wrong' }
                        }

                        foreach my $memo_key ( @memo_keys ) {
                            if ( $now_time eq $memo_key ) {
                                my $table = Text::ASCIITable->new({ 
                                        headingText => 'Memo - Viewer', 
                                        utf8        => 0,
                                });

                                my $show_memo = $redis->hmget("memo_log", "$memo_key");
                                my $show_memo_decode = decode("utf-8", $show_memo->[0]);

                                $table->setCols("Jotter- $jotter / Time- $memo_key");
                                $table->addRow("$show_memo_decode");
                                $msg->send("\n", split /\n/, $table);
                            }
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
                $msg->send("memobot status is [$flag] ...");
            }
    );
}
1;

=pod

=head1 Name 

    Hubot::Scripts::memo
 
=head1 SYNOPSIS

    Registered at the time the show memos. 
    time format - ymd-hm(2013-11-23-09:00), md-hm(11-23-09:00), hm(09:30)
    memo <time> <memo> - Show memo at <time> (ex: memo 11-23-09:00 I Love Seoul.pm)
    memo on - Start Memo Viewer.
             

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
