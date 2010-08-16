Gift :: TODO :: 1.0.0
=======================

The following features are due for completion before version 1.0.0

Add support for multiple remotes
----------------------------------

Ability to add and remove (wrap and unwrap) remote hosts

Add support to modify remote details
--------------------------------------

Updates to remote details should be editable via command line

Add 'clean' or 'fresh' deliveries
-----------------------------------

These would skip diffing, and upload the current tree regardless of
the remote state. Need to consider whether the remote should be purged

Some sort of 'pull' ability
-----------------------------

This is likely to have _heavy_ bandwidth problems, but would probably
involve comparing each file and overwriting (locally) those that differ.
However, it should still leave the local tree unmodified, allowing the
user to commit as required.