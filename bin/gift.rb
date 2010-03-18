#!/usr/bin/env ruby

# == About 
#   Gift – Git and FTP, the easy way
#   Gift provides a simple interface for pushing your site to a server that does not support git, via FTP.
#
#   This version of Gift currenly only supports the master branch of a git repository.
#
# == Examples
#   Start my initialising your FTP settings
#     $ gift wrap ftp://username:password@127.0.0.1:21
#
#   When you're ready to deploy, use:
#     $ gift deliver
#
# == Usage 
#   $ gift wrap [server-name] ftp://username:password@127.0.0.1:21
#   $ gift deliver [options]
#
#   For help use: gift -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#
# == Author
#   Nicholas Bruning
#
# == Copyright
#   Copyright (c) 2010 Nicholas Bruning. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

# use this for testing:
# ruby lib/cli.rb wrap ftp://dev+involved.com.au:d8u2gy@involved.com.au:21/gift-test

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'cli'
exit Gift::Cli.new(ARGV, STDIN).run