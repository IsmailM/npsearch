# NpHMMerApp
<!-- [![Build Status](https://travis-ci.org/wurmlab/nphmmerapp.svg?branch=master)](https://travis-ci.org/wurmlab/nphmmerapp)
[![Gem Version](https://badge.fury.io/rb/nphmmerapp.svg)](http://badge.fury.io/rb/nphmmerapp)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/wurmlab/nphmmerapp/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/wurmlab/nphmmerapp/?branch=master)
 -->






## Introduction

This is a online web application for [NpHMMer](https://github.com/IsmailM/NpHMMer). This app is currently hosted at: [nphmmer.sbcs.qmul.ac.uk](nphmmer.sbcs.qmul.ac.uk)


If you use NpHMMer in your work, please cite us as follows:
> "Moghul <em>et al.</em> (<em>in prep.</em>) NpHMMer: identifing Neuropeptide Precursors"






-
## Installation
### Installation Requirements
* Ruby (>= 2.0.0)
* HMMer (>=3.0) (Available from [here](http://hmmer.org) - Suggested Installation via [Homebrew](http://brew.sh) or [Linuxbrew](http://linuxbrew.sh) - `brew install homebrew/science/hmmer`)
* Seqtk (Available from [here](https://github.com/lh3/seqtk) - Suggested Installation via [Homebrew](http://brew.sh) or [Linuxbrew](http://linuxbrew.sh) - `brew install homebrew/science/seqtk`)
* EMBOSS (Available from [here](http://emboss.sourceforge.net) - Suggested Installation via [Homebrew](http://brew.sh) or [Linuxbrew](http://linuxbrew.sh) - `brew install homebrew/science/emboss`)
* SignalP 4.1.*z (Available from [here](http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?signalp))

### Installation (Will not work during beta)
1. Install NpHMMerApp 

```bash
gem install nphmmerapp # will not work during beta 
```

##### Running From Source (during beta)

```bash
# Clone the repository. # contact me at ismail.moghul@gmail.com to get access
git clone https://github.com/IsmailM/nphmmer.git

# Move into GeneValidatorApp source directory.
cd nphmmer

# Install bundler
gem install bundler

# Install NpHMMer
gem install ./nphmmer-0.4.1.gem

# Use bundler to install dependencies
bundle install --local

# Run NpHMMer.
bundle exec nphmmerapp -h

```




## Launch NpHMMer

To configure and launch NpHMMerApp, run the following from a command line.

```bash
nphmmerapp -S /path/to/signalp -n 8 -p 4567 
```

NpHMMerApp will automatically guide you through an interactive setup process to help locate BLAST+ binaries and ask for the location of BLAST+ databases.

That's it! Open http://localhost:4567/ and start using NpHMMer!






## Advanced Usage

See `$ nphmmerapp -h` for more information on all the options available when running NpHMMerApp.


<hr>

This program was developed at [Wurm Lab](https://wurmlab.github.io) and [QMUL](http://sbcs.qmul.ac.uk).
