# Workflow to compare NEB to Tag-Seq

configfile: "config.yml"

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
    input: expand(config["umi_labeled_dir"] + "/{sample}.fastq.gz", sample=all_samples)


rule demultiplex_tag:
    input: read1=config["read1"],
           read2=config["read2"],
           read3=config["read3"],
           barcodes=config["tagseq_barcodes_file"]
    output: temp(expand(config["demultiplexed_dir"] + "/fastq_tag/{sample}-read-{read}.fastq", sample=tagseq_samples, read=["1","2","3"])),
            temp(expand(config["demultiplexed_dir"] + "/fastq_tag/unmatched-read-{read}.fastq", read=["1","2","3"])),
            expand(config["demultiplexed_dir"] + "/fastq_tag/multimatched-read-{read}.fastq", read=["1", "2","3"])
    log: config["demultiplexed_dir"] + "/fastq_tag/barcode_splitter.log"
    shell: 'barcode_splitter \
            --split_all \
            --bcfile "{input.barcodes}" \
            --mismatches 1 --prefix "{config[demultiplexed_dir]}/fastq_tag/" \
            {input.read1:q} \
            {input.read2:q} \
            {input.read3:q} \
            --idxread 2 3 &> {log:q}'


rule move_tag_fastq:
    input: config["demultiplexed_dir"] + "/fastq_tag/{file}.fastq"
    output: temp(config["demultiplexed_dir"] + "/{file}.fq")
    shell: 'mv {input:q} {output:q}'

rule demultiplex_neb:
    input:
        read1=config["demultiplexed_dir"] + "/fastq_tag/unmatched-read-1.fastq",
        read2=config["demultiplexed_dir"] + "/fastq_tag/unmatched-read-2.fastq",
        read3=config["demultiplexed_dir"] + "/fastq_tag/unmatched-read-3.fastq",
        barcodes=config["neb_barcodes_file"]
    output:
        temp(expand(config["demultiplexed_dir"] + "/fastq_neb/{sample}-read-{read}.fastq", sample=neb_samples, read=["1", "2", "3"])),
        expand(config["demultiplexed_dir"] + "/fastq_neb/unmatched-read-{read}.fastq", read=["1", "2","3"]),
        expand(config["demultiplexed_dir"] + "/fastq_neb/multimatched-read-{read}.fastq", read=["1", "2","3"])
    log:
        config["demultiplexed_dir"] + "/fastq_neb/barcode_splitter.log"
    shell: 'barcode_splitter \
            --split_all \
            --bcfile "{input.barcodes}" \
            --mismatches 1 --prefix "{config[demultiplexed_dir]}/fastq_neb/" \
            {input.read1:q} \
            {input.read2:q} \
            {input.read3:q} \
            --idxread 2 &> {log:q}'

rule move_neb_fastq:
    input: config["demultiplexed_dir"] + "/fastq_neb/{file}.fastq"
    output: temp(config["demultiplexed_dir"] + "/{file}.fq")
    shell: 'mv {input:q} {output:q}'


rule extract_umi:
    input:
        read1=config["demultiplexed_dir"] + "/{sample}-read-1.fq",
        read3=config["demultiplexed_dir"] + "/{sample}-read-3.fq"
    output:
        config["umi_labeled_dir"] + "/{sample}.fastq.gz"
    log:
        config["umi_labeled_dir"] + "/logs/{sample}_umi_tools_extract.log"
    shell:
        "umi_tools extract "
        "-I {input.read3:q} "
        "--read2-in {input.read1:q} "
        "--bc-pattern 'XXXXXXXXNNNNNNNN' "
        "--read2-stdout "
        "--log {log:q} "
        "| pigz > {output:q}"
