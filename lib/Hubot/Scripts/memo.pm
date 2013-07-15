package Hubot::Scripts::perlstudy;

use utf8;
use strict;
use warnings;
use Encode;
use LWP::UserAgent;
use Data::Printer;
use AnyEvent::DateTime::Cron;

my $cron = AnyEvent::DateTime::Cron->new(time_zone => 'local');

sub load {
    my ( $class, $robot ) = @_;
    my $flag = 'off';
 
    $robot->hear(
        qr/^perlstudy:? on *$/i,    
        sub {
            my $msg = shift;
            my $user_input = $msg->match->[0];
            $msg->send('It has been started monitoring [cafe-perlstudy]...');

           $cron->add ( '*/10 * * * *' => sub {
                    $msg->http("http://cafe.naver.com/MyCafeIntro.nhn?clubid=18062050")->get(
                        sub {
                            my ( $body, $hdr ) = @_;
                            return if ( !$body || $hdr->{Status} !~ /^2/ );

                            my $decode_body = decode ("euc-kr", $body);


    $robot->hear(
            qr/^perlstudy:? (?:off|finsh) *$/i,

            sub {
                my $msg = shift;
                $cron->stop;
                $msg->send('It has been stoped monitoring [cafe-perlstudy]...');
                $flag = 'off';
            }
    );

    $robot->hear(
            qr/^perlstudy:? status *$/i,    

            sub {
                my $msg = shift;
                $msg->send("perlstudy status is [$flag] ...");
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
