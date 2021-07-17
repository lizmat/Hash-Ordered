use v6.c;

role Hash::Ordered:ver<0.0.1>:auth<cpan:ELIZABETH> {
    has str @.keys;

    method !add-key(\key --> Nil) {
        @!keys.push: key
    }
    method !del-key(\key --> Nil) {
        my $WHICH := key.WHICH;
        @!keys.splice: @!keys.first(*.WHICH eq $WHICH,:k), 1;
    }

    method STORE(*@values) {
        self!STORE(@values);
        self
    }

    method !STORE(@values --> Nil) {
        my $last := Mu;
        my int $found;

        for @values {
            if $_ ~~ Pair {
                self.AT-KEY(.key) = .value;
                ++$found;
            }
            elsif $_ ~~ Failure {
                .throw
            }
            elsif !$last =:= Mu {
                self.AT-KEY($last) = $_;
                ++$found;
                $last := Mu;
            }
            elsif $_ ~~ Map {
                $found += self!STORE([.pairs])
            }
            else {
                $last := $_;
            }
        }

        X::Hash::Store::OddNumber.new(:$found, :$last).throw
          unless $last =:= Mu;
    }

    method AT-KEY(::?ROLE:D: \key) is raw {
        self!add-key(key) unless self.EXISTS-KEY(key);
my \result :=
        nextcallee()(self, key)
; dd result; result
    }
    method ASSIGN-KEY(::?ROLE:D: \key, \value) is raw {
        self.AT-KEY(key) = value
    }
    method BIND-KEY(::?ROLE:D: \key, \value) is raw {
        self!add-key(key) unless self.EXISTS-KEY(key);
        nextsame;
    }
    method DELETE-KEY(::?ROLE:D: \key) {
        self!del-key(key) if self.EXISTS-KEY(key);
        nextsame;
    }

    method values(::ROLE:D:) {
        @!keys.map: { self.AT-KEY($_) }
    }
    method pairs(::ROLE:D:) {
        @!keys.map: { Pair.new: $_, self.AT-KEY($_) }
    }

    method gist(::?ROLE:D:) {
        '{' ~ self.pairs.map( *.gist).join(", ") ~ '}'
    }

    method Str(::?ROLE:D:) {
        self.pairs.join(" ")
    }

    method perl(::?ROLE:D:) is DEPRECATED("raku") {
        self.raku
    }
    method raku(::?ROLE:D:) {
        self.perlseen(self.^name, {
          ~ self.^name
          ~ '.new('
          ~ self.pairs.map({$_<>.perl}).join(',')
          ~ ')'
        })
    }
}

=begin pod

=head1 NAME

Hash::Ordered - role for ordered Hashes

=head1 SYNOPSIS

  use Hash::Ordered;

  my %m is Hash::Ordered = a => 42, b => 666;

=head1 DESCRIPTION

Exports a C<Hash::Ordered> role that can be used to indicate the implementation
of a C<Hash> in which the keys are ordered the way the C<Hash> got initialized
or any later keys got added.

Since C<Hash::Ordered> is a role, you can also use it as a base for creating
your own custom implementations of hashes.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Ordered .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018,2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=raku expandtab sw=4
