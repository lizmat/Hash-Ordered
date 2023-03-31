use v6.c;

use Hash::Agnostic:ver<0.0.10>:auth<zef:lizmat>;

role Hash::Ordered:ver<0.0.2>:auth<zef:lizmat>
  does Hash::Agnostic
{
    has %!indices;
    has str @.keys;
    has Mu  @.values;

    method !KEY-POS(\key) is raw {
        %!indices.AT-KEY(key) // do {
            my int $index = @!keys.elems;
            @!keys.ASSIGN-POS: $index, key;
            %!indices.BIND-KEY: key, $index;
        }
    }

    method AT-KEY(::?ROLE:D: \key) is raw {
        with %!indices.AT-KEY(key) {
            @!values.AT-POS($_)
        }
        else {
            Proxy.new(
                FETCH => { %!indices.AT-KEY(key) andthen @!values.AT-POS($_) orelse Nil },
                STORE => -> $, \value { self.ASSIGN-KEY(key, value) }
            )
        }
    }

    method ASSIGN-KEY(::?ROLE:D: \key, \value) is raw {
        @!values.ASSIGN-POS: self!KEY-POS(key), value
    }

    method BIND-KEY(::?ROLE:D: \key, \value) is raw {
        @!values.BIND-POS: self!KEY-POS(key), value
    }

    method CLEAR(::?ROLE:D:) {
        %!indices = @!keys = @!values = Empty;
    }

    method DELETE-KEY(::?ROLE:D: \key) {
        with %!indices.DELETE-KEY(key) -> \index {
            my \value = @!values[index];

            @!keys.splice:   index, 1;
            @!values.splice: index, 1;

            %!indices.AT-KEY(@!keys.AT-POS($_))-- for index .. @!keys.end;

            value
        }
    }

    method EXISTS-KEY(::?ROLE:D: \key) {
        %!indices.EXISTS-KEY(key)
    }

    method gist(::?ROLE:D:) {
        '{' ~ self.pairs.map( *.gist).join(", ") ~ '}'
    }

    method Str(::?ROLE:D:) {
        self.pairs.join(" ")
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

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-Ordered .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=raku expandtab sw=4
