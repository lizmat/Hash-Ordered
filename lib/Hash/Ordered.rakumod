use v6.c;

use Hash::Agnostic:ver<0.0.17>:auth<zef:lizmat>;

role Hash::Ordered does Hash::Agnostic {
    has %!indices;
    has str @.keys;
    has Mu  @.values;

    method AT-KEY(::?ROLE:D: \key) is raw {
        Proxy.new(
            FETCH => {
                with %!indices.AT-KEY(key) {
                    @!values.AT-POS($_)
                }
                else { Nil }
            },
            STORE => -> $, \value {
                with %!indices.AT-KEY(key) {
                    @!values.ASSIGN-POS($_, value)
                }
                else {
                    my int $index = @!keys.elems;
                    @!keys.ASSIGN-POS($index, key);
                    %!indices.BIND-KEY(key, $index);
                    @!values.ASSIGN-POS($index, value)
                }
            }
        )
    }

    method BIND-KEY(::?ROLE:D: \key, \value) is raw {
        with %!indices.AT-KEY(key) -> \index {
            @!values.BIND-POS(index, value)
        }
        else {
            my int $index = @!keys.elems;
            @!keys.ASSIGN-POS($index, key);
            @!values.BIND-POS($index, value);
            %!indices.BIND-KEY(key, $index);
        }
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

    multi method gist(::?ROLE:D:) {
        '{' ~ self.pairs.map( *.gist).join(", ") ~ '}'
    }

    multi method Str(::?ROLE:D:) {
        self.pairs.join(" ")
    }

    multi method raku(::?ROLE:D:) {
        self.rakuseen(self.^name, {
          ~ self.^name
          ~ '.new('
          ~ self.pairs.map({$_<>.raku}).join(',')
          ~ ')'
        })
    }
}

=begin pod

=head1 NAME

Hash::Ordered - role for ordered Hashes

=head1 SYNOPSIS

=begin code :lang<raku>

use Hash::Ordered;

my %m is Hash::Ordered = a => 42, b => 666;

=end code

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

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2021, 2023, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=raku expandtab sw=4
