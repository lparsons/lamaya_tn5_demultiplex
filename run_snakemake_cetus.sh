#!/bin/bash

# TODO Check for existence of config.yaml and cluster.yaml

# TODO Optional parameters to specify config and cluster files

snakemake --cluster-config 'cluster_config.cetus.yml' \
          --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --time={cluster.time} --qos={cluster.qos}" \
          --use-conda -w 60 -rp -j 1000 "$@"
