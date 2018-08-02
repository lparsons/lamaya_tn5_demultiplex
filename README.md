# Snakemake workflow: TN5 Demultiplex

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.2.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/lamaya_tn5_demultiplex.svg?branch=master)](https://travis-ci.org/snakemake-workflows/lamaya_tn5_demultiplex)

Demultiplex TN5 data

This is the template for a new Snakemake workflow. Replace this text with a comprehensive description, covering the purpose and domain.
Insert your code into the respective folders, i.e. `scripts`, `rules` and `envs`. Define the entry point of the workflow in the `Snakefile` and the main configuration in the `config.yaml` file.

The workflow is written using [Snakemake](https://snakemake.readthedocs.io/).

Dependencies are installed using [Bioconda](https://bioconda.github.io/) where possible.

## Setup environment and run workflow

1.  Clone workflow into working directory

    ```
    git clone <repo> <dir>
    cd <dir>
    ```

2.  Download input data

    Copy data from [URL]() to `data` directory

3.  Edit config as needed

    ```
    cp config.yaml.sample config.yaml
    nano config.yaml
    ```

4.  Install dependencies into isolated environment

    ```
    conda env create -n <project> --file environment.yaml
    ```

5.  Activate environment

    ```
    source activate <project>
    ```

6.  Execute workflow

    ```
    snakemake -n
    ```


## Running workflow on `gen-comp1`

```
snakemake --cluster-config cetus_cluster.yaml \
          --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos}" \
          --use-conda -w 60 -rp -j 1000
```

## Testing

Tests cases are in the subfolder `.test`. They should be executed via continuous integration with Travis CI.
