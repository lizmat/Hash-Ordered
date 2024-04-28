[![Actions Status](https://github.com/lizmat/Hash-Ordered/workflows/test/badge.svg)](https://github.com/lizmat/Hash-Ordered/actions)

NAME
====

Hash::Ordered - role for ordered Hashes

SYNOPSIS
========

    use Hash::Ordered;

    my %m is Hash::Ordered = a => 42, b => 666;

DESCRIPTION
===========

Exports a `Hash::Ordered` role that can be used to indicate the implementation of a `Hash` in which the keys are ordered the way the `Hash` got initialized or any later keys got added.

Since `Hash::Ordered` is a role, you can also use it as a base for creating your own custom implementations of hashes.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Hash-Ordered . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2021, 2023, 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

