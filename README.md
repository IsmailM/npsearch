# NpSearch

> Currently work in progress - not ready for production




## Introduction

NpSearch is a tool for identifying neuropeptides and compromises of two parts:

- NpSearch-Novel: a command-line tool for identifying novel neuropeptides using a feature-based approach.
- NpSearch-HMM: a command-line tool and web application for identifying homologs to known neuropeptides using Hidden Markov Models.


NpSearch-HMM is currently hosted at: [https://npsearch.co.uk](https://npsearch.co.uk)


If you use NpSearch in your work, please cite us as follows:
> "Moghul <em>et al.</em> (<em>in prep.</em>) NpSearch: identifing Neuropeptide Precursors"




## Installation
### Installation Requirements
* Ruby (>= 2.5.0)
* HMMer (>=3.2) (Available from [here](http://hmmer.org)
* Seqtk (Available from [here](https://github.com/lh3/seqtk)
* EMBOSS (Available from [here](http://emboss.sourceforge.net)
* SignalP 4.1.*z (Available from [here](http://www.cbs.dtu.dk/cgi-bin/nph-sw_request?signalp))


### Installation (Will not work during beta)
1. Install NpSearch

```bash
# gem install npsearch # will not work during beta 
```

##### Running From Source (during beta)

```bash
# Clone the repository
git clone https://github.com/IsmailM/npsearch.git

# Move into NpSearch source directory.
cd npsearch

# Install bundler
gem install bundler

# Use bundler to install dependencies
bundle install

# Run NpSearch.
bundle exec npsearch app -h
# To use Google Login - there are further steps to take on the Gooogle Admin dashboard to get API keys..

```




## Launch NpSearch

### NpSearch-Novel
...

### NpSearch-HMM command line tool


### NpSearch-HMM web application

To configure and launch NpSearch-HMM as an web app, run the following from a command line.

```bash
npsearch app -S /path/to/signalp -n 8 -p 4567 
```

That's it! Open http://localhost:4567/ and start using NpSearch!

See `npsearch app -h` for more information on all the options available when running NpSearch.







<hr>

This program was developed at [Elphick Lab](http://www.sbcs.qmul.ac.uk/staff/mauriceelphick.html) & [Wurm Lab](https://wurmlab.github.io) at [QMUL](http://sbcs.qmul.ac.uk).
