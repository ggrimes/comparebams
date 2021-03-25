params.bam = "*.bam*"
params.bs = 10000
params.blackListFileName = ""
params.outdir = "results"
log.info """\
         BAMCOMPARE - N F   P I P E L I N E
         ===================================
         bams         : ${params.bam}
         outdir       : ${params.outdir}
         binSize      : ${params.bs}
         """
         .stripIndent()


bam_ch = Channel.fromPath(params.bam)
whatToPlot = Channel.from("scatterplot","heatmap")
method = Channel.from("spearman","pearson")
blackListFileName = Channel.fromPath(params.blackListFileName)

/*
*https://deeptools.readthedocs.io/en/develop/content/tools/multiBamSummary.html
*/
process multiBamSummary{


cpus 16

input:
  path bams from bam_ch.collect()
  path blackListFileName from blackListFileName

output:
  path "results.npz" into   multiBamSummary_out,mbs_pca_in_ch


script:
  """
  multiBamSummary bins \
  --smartLabels \
  --minMappingQuality 30 \
  --ignoreDuplicates \
  --blackListFileName ${params.blackListFileName} \
  -bs $params.bs \
  -p ${task.cpus} \
  --bamfiles *.bam \
  -o results.npz
  """

}

/*
*https://deeptools.readthedocs.io/en/develop/content/tools/plotCorrelation.html?highlight=plotCorrelation
*/

process plotCorrelation {


publishDir "$params.outdir", mode: 'copy'

input:
  path input from multiBamSummary_out
  each whatplot from whatToPlot
  each method from method
output:
  path "*bigwigScores*" into cor_out

script:
"""
plotCorrelation \
-in ${input} \
--corMethod $method \
--skipZeros \
--removeOutliers \
--plotTitle "${method} Correlation of Average Scores" \
--whatToPlot ${whatplot} \
--colorMap Blues \
-o ${whatplot}_${method}Corr_bigwigScores.png   \
--outFileCorMatrix ${method}Corr_bigwigScores.tab
"""

}

/*
*https://deeptools.readthedocs.io/en/develop/content/tools/plotPCA.html
*/

process plotPCA {


publishDir "$params.outdir", mode: 'copy'

input:
path input from mbs_pca_in_ch

output:
path "PCA_readCounts.png" into pca

script:
"""
   plotPCA -in results.npz \
  -o PCA_readCounts.png \
  -T "PCA of read counts"
"""

}
