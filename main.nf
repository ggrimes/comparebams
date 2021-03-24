
params.binSize = 10000
params.bam = "*.bam"


bam_ch = Channel.fromPath(params.bam)

/*
*https://deeptools.readthedocs.io/en/develop/content/tools/multiBamSummary.html
*/
process multiBamSummary{

conda "environment.yml"
cpus 2

input:
  path bams from bam_ch


output:
  path "results.npz" into   multiBamSummary_out


script:
  """
  multiBamSummary bins \
  -p ${task.cpus} \
  --bamfiles *.bam \
  -o results.npz
  """

}

/*
*https://deeptools.readthedocs.io/en/develop/content/tools/plotCorrelation.html?highlight=plotCorrelation
*/

process plotCorrelation {

conda "environment.yml"
publishDir "results", mode: 'copy'

input:
  path input from multiBamSummary_out

output:
  path "*PearsonCorr*" into cor_out

script:
"""
plotCorrelation \
-in ${input} \
--corMethod pearson \
--skipZeros \
--plotTitle "Pearson Correlation of Average Scores" \
--whatToPlot scatterplot \
-o scatterplot_PearsonCorr_bigwigScores.png   \
--outFileCorMatrix PearsonCorr_bigwigScores.tab
"""

}
