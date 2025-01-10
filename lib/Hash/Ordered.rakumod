use Hash::Agnostic:ver<0.0.17+>:auth<zef:lizmat>;

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

# vim: expandtab sw=4
