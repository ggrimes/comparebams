# comparebams

Use [deeptools](https://deeptools.readthedocs.io/en/develop/index.html) to

1. Perform a multiBamSummary: Calculate the coverage for bam file in n bins
1. Plot heatmaps and scatterplots with Pearson and Spearman correlation metric
1. Plot PCA for using 1000 most variable bins


## Installation

1. Install nextflow and conda


## Usage

~~~
nextflow run main.nf \
--bam "bamfolder/*.bam*" \
--bs 10000
--outdir "results"
~~~


## output

In the outdir
1. heatmaps
1. scatterplots
1. PCA biplot PC1,PC2
