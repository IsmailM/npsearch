# NeuroHmmerApp
[![Build Status](https://travis-ci.org/wurmlab/neurohmmerapp.svg?branch=master)](https://travis-ci.org/wurmlab/neurohmmerapp)
[![Gem Version](https://badge.fury.io/rb/neurohmmerapp.svg)](http://badge.fury.io/rb/neurohmmerapp)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/wurmlab/neurohmmerapp/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/wurmlab/neurohmmerapp/?branch=master)







## Introduction

This is a online web application for [Neurohmmer](https://github.com/wurmlab/neurohmmer). This app is currently hosted at: ... 


If you use Neurohmmer in your work, please cite us as follows:
> "Moghul MI, Elphick M & Wurm Y (<em>in prep.</em>) NeuroHmmer: identify Neuropeptide Precursors"






-
## Installation
### Installation Requirements
* Ruby (>= 2.0.0)
* HMMer (>=3.0)
 

### Installation
Simply run the following command in the terminal.

```bash
gem install neurohmmerapp
```

If that doesn't work, try `sudo gem install neurohmmerapp` instead.

##### Running From Source (Not Recommended)
It is also possible to run from source. However, this is not recommended.

```bash
# Clone the repository.
git clone https://github.com/wurmlab/neurohmmerapp.git

# Move into GeneValidatorApp source directory.
cd neurohmmerapp

# Install bundler
gem install bundler

# Use bundler to install dependencies
bundle install

# Optional: run tests and build the gem from source
bundle exec rake

# Run NeuroHmmer.
bundle exec neurohmmerapp -h
# note that `bundle exec` executes NeuroHmmerApp in the context of the bundle

# Alternativaly, install NeuroHmmerApp as a gem
bundle exec rake install
neurohmmerapp -h
```




## Launch NeuroHmmer

To configure and launch NeuroHmmerApp, run the following from a command line.

```bash
neurohmmerapp
```

NeuroHmmerApp will automatically guide you through an interactive setup process to help locate BLAST+ binaries and ask for the location of BLAST+ databases.

That's it! Open http://localhost:4567/ and start using NeuroHmmer!






## Advanced Usage

See `$ neurohmmerapp -h` for more information on all the options available when running NeuroHmmerApp.


<hr>

This program was developed at [Wurm Lab](https://wurmlab.github.io), [QMUL](http://sbcs.qmul.ac.uk).
