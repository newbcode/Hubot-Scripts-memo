package Hubot::Scripts::memo;

use 5.010;
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
            qr/^memo (.*?) (.+)/i,

            sub {
                my $msg = shift;

                my $sender = $msg->message->user->{name};
                my $reserv_time = $msg->match->[0];
                my $user_memo = $msg->match->[1];
                my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
                my $ymd = $dt->ymd;
                my $year = $dt->year;
                my $month = $dt->month;
                my $day = $dt->day;
                my $hour = $dt->hour;
                my $min = $dt->minute;
                my $now_time;

                given ($reserv_time) {
                    when ( /^\d\d\d\d\-\d\d\-\d\d\-\d\d:\d\d$/ ) { 
                        $now_time = $reserv_time }
                    when ( /^\d\d\-\d\d\-\d\d:\d\d$/ ) { 
                        $now_time = "$year"."-$reserv_time" }
                    when ( /^\d\d\:\d\d$/ ) { 
                        $now_time = "$year"."-$month"."-$day"."-$reserv_time" }
                    default { $msg->send( "Time format is wrong!") }
                }

                if (defined($now_time)) {
                    $msg->send($sender);
                    $msg->send($now_time);
                    $msg->send($user_memo);
                }
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
