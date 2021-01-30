package Shell::Autobox;

use strict;
use warnings;

use base qw(autobox);

use Carp qw(confess);
use IPC::Run3 qw(run3);

# XXX this declaration must be on a single line
# https://metacpan.org/pod/version#How-to-declare()-a-dotted-decimal-version
use version; our $VERSION = version->declare('v1.0.0');

sub import {
    my $class  = shift;
    my $caller = (caller)[0];

    for my $program (@_) {
        my $sub = sub {
            my $input = shift;
            my $args = join ' ', @_;
            my $maybe_args = length($args) ? " $args" : '';
            my $command = "$program$maybe_args";
            my $stdin = (defined($input) && length($input)) ? \$input : undef;

            run3($command, $stdin, \my $stdout, \my $stderr, {
                return_if_system_error => 1,
            });

            my $error = (defined($stderr) && $stderr =~ /\S/) ? ": $stderr" : '';
            my $message = "$command$error";

            if ($?) {
                confess "can't exec $message";
            } elsif ($error) {
                warn "error running $message";
            }

            return (defined($stdout) && length($stdout)) ? $stdout : '';
        };

        {
            no strict 'refs';
            *{"$caller\::$program"} = $sub;
        }
    }

    $class->SUPER::import(SCALAR => $caller);
}

1;

__END__

=head1 NAME

Shell::Autobox - pipe Perl strings through shell commands

=head1 SYNOPSIS

    use Shell::Autobox qw(xmllint);

    my $xml = '<foo bar="baz"><bar /><baz /></foo>';
    my $pretty = $xml->xmllint('--format', '-');

=head1 DESCRIPTION

Shell::Autobox provides an easy way to pipe Perl strings through shell commands.
Commands passed as arguments to the C<use Shell::Autobox> statement are
installed as subroutines in the calling package, and that package is then
registered as the handler for methods called on ordinary (i.e. non-reference)
scalars.

When a method corresponding to a registered command is called on a scalar, the
scalar is passed as the command's standard input; additional arguments are
passed through as a space-separated list of options, and - if no error occurs -
the command's standard output is returned. This can then be piped into other
commands.

The registered methods can also be called as regular functions, e.g.:

    use Shell::Autobox qw(cut);

    my $bar = cut('foo:bar:baz', '-d:', '-f2');

=head2 EXPORT

None by default.

=head1 VERSION

1.0.0

=head1 SEE ALSO

=over

=item * L<autobox>

=item * L<autobox::Core>

=item * L<Shell>

=back

=head1 AUTHOR

chocolateboy <chocolate@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2005-2021 by chocolateboy.

This library is free software; you can redistribute it and/or modify it under
the terms of the L<Artistic License 2.0|https://www.opensource.org/licenses/artistic-license-2.0.php>.

=cut
