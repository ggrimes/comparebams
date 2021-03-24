params.binSize = 10000
params.bam = "*.bam*"


log.info """\
         R N A S E Q - N F   P I P E L I N E
         ===================================
         SRA:         : ${params.outdir}
         outdir:      : ${params.sra}
         kmers        : ${kmers}
         """
         .stripIndent()


bam_ch = Channel.fromPath(params.bam)
whatToPlot = Channel.fromValues("scatterplot","heatmap")
/*
*https://deeptools.readthedocs.io/en/develop/content/tools/multiBamSummary.html
*/
process multiBamSummary{

conda "environment.yml"
cpus 16

input:
  path bams from bam_ch.collect()


output:
  path "results.npz" into   multiBamSummary_out


script:
  """
  multiBamSummary bins \
  -r chr19 \
  --smartLabels \
  -bs 10000000 \
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
  each whatplot from whatToPlot

output:
  path "${whatplot}_PearsonCorr_bigwigScores.png " into cor_out

script:
"""
plotCorrelation \
-in ${input} \
--corMethod pearson \
--skipZeros \
--plotTitle "Pearson Correlation of Average Scores" \
--whatToPlot ${whatplot} \
-o ${whatplot}_PearsonCorr_bigwigScores.png   \
--outFileCorMatrix PearsonCorr_bigwigScores.tab
"""

}
