# Workflow to compare NEB to Tag-Seq

configfile: "config.yaml"

import csv
with open(config["neb_barcodes_file"]) as tsvfile:
    tsvreader = csv.reader(tsvfile, delimiter="\t")
    neb_samples=[]
    for row in tsvreader:
        neb_samples.append(row[0])
with open(config["tagseq_barcodes_file"]) as tsvfile:
    tsvreader = csv.reader(tsvfile, delimiter="\t")
    tagseq_samples=[]
    for row in tsvreader:
        tagseq_samples.append(row[0])
all_samples = neb_samples + tagseq_samples

rule all:
    input: expand(config["output_dir"] + "/{sample}-read-{read}.fastq.gz", sample=all_samples, read=["1","2","3"])


rule demultiplex_tag:
    input: read1=config["read1"],
           read2=config["read2"],
           read3=config["read3"],
           barcodes=config["tagseq_barcodes_file"]
    output: temp(expand(config["output_dir"] + "/fastq_tag/{sample}-read-{read}.fastq", sample=tagseq_samples, read=["1","2","3"])),
            temp(expand(config["output_dir"] + "/fastq_tag/unmatched-read-{read}.fastq", read=["1","2","3"])),
            expand(config["output_dir"] + "/fastq_tag/multimatched-read-{read}.fastq", read=["1", "2","3"])
    log: config["output_dir"] + "/fastq_tag/barcode_splitter.log"
    shell: 'barcode_splitter \
            --split_all \
            --bcfile "{input.barcodes}" \
            --mismatches 1 --prefix "{config[output_dir]}/fastq_tag/" \
            {input.read1:q} \
            {input.read2:q} \
            {input.read3:q} \
            --idxread 2 3 &> {log:q}'


rule move_tag_fastq:
    input: config["output_dir"] + "/fastq_tag/{file}.fastq"
    output: config["output_dir"] + "/{file}.fastq.gz"
    shell: 'pigz -p {threads} -c {input:q} >{output:q}'

rule demultiplex_neb:
    input:
        read1=config["output_dir"] + "/fastq_tag/unmatched-read-1.fastq",
        read2=config["output_dir"] + "/fastq_tag/unmatched-read-2.fastq",
        read3=config["output_dir"] + "/fastq_tag/unmatched-read-3.fastq",
        barcodes=config["neb_barcodes_file"]
    output:
        temp(expand(config["output_dir"] + "/fastq_neb/{sample}-read-{read}.fastq", sample=neb_samples, read=["1", "2", "3"])),
        expand(config["output_dir"] + "/fastq_neb/unmatched-read-{read}.fastq", read=["1", "2","3"]),
        expand(config["output_dir"] + "/fastq_neb/multimatched-read-{read}.fastq", read=["1", "2","3"])
    log:
        config["output_dir"] + "/fastq_neb/barcode_splitter.log"
    shell: 'barcode_splitter \
            --split_all \
            --bcfile "{input.barcodes}" \
            --mismatches 1 --prefix "{config[output_dir]}/fastq_neb/" \
            {input.read1:q} \
            {input.read2:q} \
            {input.read3:q} \
            --idxread 2 &> {log:q}'

rule move_neb_fastq:
    input: config["output_dir"] + "/fastq_neb/{file}.fastq"
    output: config["output_dir"] + "/{file}.fastq.gz"
    shell: 'pigz -p {threads} -c {input:q} >{output:q}'
