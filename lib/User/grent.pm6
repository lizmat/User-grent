use v6.*;

our $gr_name    is export(:FIELDS);
our $gr_passwd  is export(:FIELDS);
our $gr_gid     is export(:FIELDS);
our @gr_members is export(:FIELDS);

class User::grent:ver<0.0.3>:auth<cpan:ELIZABETH> {
    has Str $.name;
    has Str $.passwd;
    has Int $.gid;
    has @.members;
}

sub populate(@fields) {
    if @fields {
        User::grent.new(
          name    => ($gr_name    = @fields[0]),
          passwd  => ($gr_passwd  = @fields[1]),
          gid     => ($gr_gid     = @fields[2]),
          members => (@gr_members = @fields[3].split(" ")),
        )
    }
    else {
          $gr_name    = Str;
          $gr_passwd  = Str;
          $gr_gid     = Int;
          @gr_members = ();
          Nil
    }
}

my sub getgrnam(Str() $name) is export(:DEFAULT:FIELDS) {
    use P5getgrnam:ver<0.0.8>:auth<cpan:ELIZABETH>;
    populate(getgrnam($name))
}

my sub getgrgid(Int() $gid) is export(:DEFAULT:FIELDS) {
    use P5getgrnam:ver<0.0.8>:auth<cpan:ELIZABETH>;
    populate(getgrgid($gid))
}

my sub getgrent() is export(:DEFAULT:FIELDS) {
    use P5getgrnam:ver<0.0.8>:auth<cpan:ELIZABETH>;
    populate(getgrent)
}

my proto sub getgr(|) is export(:DEFAULT:FIELDS) {*}
my multi sub getgr(Int:D $gid) is export(:DEFAULT:FIELDS) { getgrgid($gid) }
my multi sub getgr(Str:D $nam) is export(:DEFAULT:FIELDS) { getgrnam($nam) }

my constant &setgrent is export(:DEFAULT:FIELDS) = do {
    use P5getgrnam:ver<0.0.8>:auth<cpan:ELIZABETH>;
    &setgrent
}
my constant &endgrent is export(:DEFAULT:FIELDS) = do {
    use P5getgrnam:ver<0.0.8>:auth<cpan:ELIZABETH>;
    &endgrent
}

=begin pod

=head1 NAME

Raku port of Perl's User::grent module

=head1 SYNOPSIS

    use User::grent;
    $gr = getgrgid(0) or die "No group zero";
    if $gr.name eq 'wheel' && $gr.members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    use User::grent qw(:FIELDS);
    getgrgid(0) or die "No group zero";
    if $gr_name eq 'wheel' && @gr_members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    $gr = getgr($whoever);

=head1 DESCRIPTION

This module tries to mimic the behaviour of Perl's C<User::grent> module
as closely as possible in the Raku Programming Language.

This module's default exports C<getgrent>, C<getgrgid>, and C<getgrnam>
functions, replacing them with versions that return C<User::grent> objects.
This object has methods that return the similarly named structure field name
from the C's passwd structure from grp.h; namely name, passwd, gid, and members
(not mem). The first three return scalars, the last an array.

You may also import all the structure fields directly into your namespace as
regular variables using the :FIELDS import tag. (Note that this still exports
the functions.) Access these fields as variables named with a preceding gr_.
Thus, C<$group_obj.gid> corresponds to C<$gr_gid> if you import the fields.

The C<getgr> function is a simple front-end that forwards a numeric argumenti
to C<getgrgid> and the rest to C<getgrnam>.

=head1 PORTING CAVEATS

This module depends on the availability of POSIX semantics.  This is
generally not available on Windows, so this module will probably not work
on Windows.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/User-grent . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2020 Elizabeth Mattijsen

Re-imagined from Perl as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
