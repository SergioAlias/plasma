rule classify_asv:
    input:
        dada2_seqs = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/rep-seqs.qza",
        dada2_table = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/table.qza",
        metadata = config["metadata"],
        classifier = config["db_dir"] + "/" + config["db_file"]
    output:
        taxonomy_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/taxonomy.qza",
        taxonomy_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/taxonomy.qzv",
        taxonomy_barplot = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/barplot.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy",
        nthreads = config["sklearn_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        time qiime feature-classifier classify-sklearn \
          --i-classifier {input.classifier} \
          --i-reads {input.dada2_seqs} \
          --p-n-jobs {params.nthreads} \
          --o-classification {output.taxonomy_qza}
        time qiime metadata tabulate \
          --m-input-file {output.taxonomy_qza} \
          --o-visualization {output.taxonomy_qzv}
        time qiime taxa barplot \
          --i-table {input.dada2_table}  \
          --i-taxonomy {output.taxonomy_qza} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.taxonomy_barplot}
        """