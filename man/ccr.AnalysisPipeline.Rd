\name{ccr.AnalysisPipeline}
\alias{ccr.AnalysisPipeline}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  CRISPRcleanR analysis pipeline.
}
\description{
 This function runs sequentially all the main steps of a CRISPRscreenR analysis, adding extra control steps to ensure the consistency between the raw counts and the library used in the screen.
  The pipeline takes as input raw count/matrix or lists of FASTQ/BAM files and allows the user to define all the parameters used in the analysis steps.
  All the output files will be generated in the outdir folder and organised in two separate subfolders: "data" containing all results in the TXT format; "pdf" containing all the plots in PDF format.
  An optional "bam" folder containing all the BAM files generated by the alignment will be available if a list of FASTQ files is used as input.
 \cr
}
\usage{
  ccr.AnalysisPipeline(
    # Library relaated parameters
    library_builtin = NULL,
    library_file = NULL,

    # Counts / FCs related parameters
    file_counts = NULL,

    # FASTQ / BAM options
    files_FASTQ_controls = NULL,
    files_FASTQ_samples = NULL,
    files_BAM_controls = NULL,
    files_BAM_samples = NULL,
    aligner = c("Rsubreads", "mageck"),
    maxMismatches = 0,
    nTrim5 = "0",
    nTrim3 = "0",
    nBestLocations = 2,
    strand = c("F", "R", "*"),
    duplicatedSeq = c("keep", "exclude"),
    nthreads = 1,
    indexMemory = 2000,
    fastqc_plots = FALSE,

    # Main analysis parameters
    EXPname = "",
    outdir = "./",
    ncontrols = 1,
    min_reads = 30,
    method = "ScalingByTotalReads",
    FDRth = 0.05,

    # Correction parameters
    min.ngenes = 3,
    alpha = 0.01,
    nperm = 10000,
    p.method ="hybrid",
    min.width = 2,
    kmax = 25,
    nmin = 200,
    eta = 0.05,
    trim = 0.025,
    undo.splits = "none",
    undo.prune = 0.05,
    undo.SD = 3,

    # Run MAGeCK
    run_mageck = FALSE,
    path_to_mageck = "mageck",

    # Other options undocumented
    is_web = FALSE,
    retrun_data = FALSE,
    nseed = 0xA5EED,
    verbose = -1,
    columns_map = c()
  )
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{library_builtin}{
    A string containing the name of one of the library whose annotation is available in CRISPRcleanR.
  }
  \item{library_file}{
    A string specifying the path to a file containing the sgRNA annotations in TXT / TSV format, with columns for sgRNA ID ("CODE"), targeted genes ("GENES"), genomic coordinates and possibly other information. This should be formatted as the \code{\link{KY_Library_v1.0}} data object containing the annotation of the sgRNA library presented in [1].
    If FASTQ files are used as input, the annotation must include also a column "seq" with the nucleotidic sequence of the sgRNAs.
    This argument is ignored if a built-in library is specified.
  }
  \item{file_counts}{
    A string specifying the path of a tsv file containing the raw sgRNA counts. This must be a tab delimited file with one row per sgRNA and the following columns/headers: 
    \itemize{
      \item sgRNA: containing alphanumerical identifiers of the sgRNA under consideration;
      \item gene: containing HGNC symbols of the genes targeted by the sgRNA under consideration; 
    }
    followed by the columns containing the sgRNAs' counts for the controls and columns for library transfected samples.
    The argument must be NULL if FASTQ / BAM files are specified as input.
  }
  \item{files_FASTQ_controls}{
    List of FASTQ files used to generate the counts for the control samples. Each file name should include the path. 
    If present, the name of each element of the list will be used as sample name for the BAM files and in the count matrix.
    The argument must be NULL if counts / BAM files are specified as input.
  }
  \item{files_FASTQ_samples}{
    List of FASTQ files used to generate the counts for the samples. Each file name should include the path. 
    If present, the name of each element of the list will be used as sample name for the BAM files and in the count matrix.
    The argument must be NULL if counts / BAM files are specified as input.
  }
  \item{files_BAM_controls}{
    List of BAM files used to generate the counts for the control samples. Each file name should include the path. 
    If present, the name of each element of the list will be used as sample name in the count matrix.
    The argument must be NULL if counts / FASTQ files are specified as input.
  }
  \item{files_BAM_samples}{
    List of BAM files used to generate the counts for the samples. Each file name should include the path. 
    If present, the name of each element of the list will be used as sample name in the count matrix.
    The argument must be NULL if counts / FASTQ files are specified as input.
  }
  \item{aligner}{
    A string specifying the aligner used to map the reads to the libary. 
    The possible options are "Rsubreads" (default) and "mageck" if the MAGeCK application [2] is installed.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{maxMismatches}{
    Integer number containing the Ns allowed to count the reads. 
    The function will consider as valid only the reads with a number of matched bases equal or greater than the length of the sgRNA sequence, provided in the annotation library, minus the maxMismatches parameter.
    The parameter is ignored if the input are not FASTQ / BAM files.
  }
  \item{nTrim5}{
    Numeric value giving the number of bases trimmed off from 5' end of each read. 0 by default.
    If aligner = "Rsubreads" (default), the parameter accepts only numeric values. 
    If MAGeCK is used, the parameter can specify multiple trimming lengths separated by comma (for example "7,8"), or can be set to "AUTO" to allow MAGeCK determine the trimming length.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{nTrim3}{
    Numeric value giving the number of bases trimmed off from 3' end of each read. 0 by default.
    If aligner = "Rsubreads" (the default ) the parameter accept only numeric values. 
    The parameter is ignored if the input are not FASTQ files or if MAGeCK is used as aligner.
  }
  \item{nBestLocations}{
    Numeric value specifying the maximal number of equally-best mapping locations that will be reported for a multi-mapping read (max 16). 2 by default.
    Different tabs will be included to the aligned sequecnes to specify the number of alignments reported. Please refer to the Rsubread [1] user guide for a compelete description.
    The parameter is ignored if the input are not FASTQ files or if MAGeCK is used as aligner.
  }
  \item{strand}{
    A string specifying the strand of the alinement used to count the reads. It accepts three different options: "F" to count only the reads equal to the sgRNA sequence (default); "R" to count only the reads complementary to the sgRNA sequence; "*" all the reads without any strand filter. See the function description for details.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{duplicatedSeq}{
    A string defining the strategy to deal with the duplicated sequences in the library index creation. See ccr.CreateLibraryIndex for details.
    The possible options are "keep" (the default) or "exclude". The "keep" option will maintain the first occurrence of the duplicates sequences while the "exclude" option will remove all the sgRNA whose nucleotidic sequence occur more than once.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{nthreads}{
    Numeric value giving the number of threads used for mapping. 1 by default.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{indexMemory}{
    A numeric value specifying the amount of memory (in megabytes) used for storing the index during read mapping. 2000 MB by default.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{fastqc_plots}{
    A boolean value specifying if the QC plots for each FASTQ files will be generated during the alignment.
    The QC plots are created using the rqc function in the Rqc package.
    All the plots for each FASTQ file are collected in one HTML file named as the BAM file created in the alignment.
    The parameter is ignored if the input are not FASTQ files.
  }
  \item{EXPname}{
    A string specifying the name of the experiment. This will be used to as label in the output plots.
  }
  \item{outdir}{
    A string specifying folder where all the results will be saved. The function will create a "data" subfolder to store all the data in TSV format, a "pdf" subfolder to store all the plots in PRD format and an optional "bam" folder to store the BAM filed generated by the alignment of the reads if the input was based on FASTQ files.  
  }
  \item{ncontrols}{
    A numerical value used by the \link{ccr.NormfoldChanges} indicating the number of control replicates. It represents the columns to be considered as control counts after the first two, in the inputted tsv file. 1 by default.
    The parameter will not be considered when the input are FASTQ/BAM file. In this case the counts obtained by the files listed in files_FASTQ_controls / files_BAM_controls parameters will be used as controls.
  }
  \item{min_reads}{
   A numerical value used by the \link{ccr.NormfoldChanges} to define a filter threshold value for sgRNAs, based on their average counts in the control sample. Specifically, it indicates the minimal number of counts that each individual sgRNA needs to have in the controls (on average) in order to be included in the output. 30 by default.
  }
  \item{method}{
    A string specifying the normalisation method: 'ScalingByTotalReads' for scaling samples by total numbers or reads (default), 'MedRatios' to use the median of ratios method [1], or a gene name for scaling samples by total number of reads of the guides targeting that gene.
  }
  \item{FDRth}{
    If different from NULL, will be a numerical value >=0 and <=1 specifying the false discovery rate threshold at which fixed recall will be computed. In this case an horizontal dashed line will be added to the ROC and PrRc plots at the resulting recall and its value will be visualised in the legend. 0.05 by default
  }
  \item{min.ngenes}{
    A numerical value (>0) used by the \link{ccr.GWclean} specifying the minimal number of different genes that the set of sgRNAs within a region of estimated equal logFCs should target in order for their logFCs to be corrected, i.e. mean centred. 3 by default.
  }
  \item{alpha}{
    A numerical value used by the \link{ccr.GWclean} specifying the significance levels for the test to accept change-points (see DNAcopy). 0.01 by default.
  }
  \item{nperm}{
    A numerical value used by the \link{ccr.GWclean} specifying the number of permutations used for p-value computation (see DNAcopy). 10000 by default.
  }
  \item{p.method}{
    A string used by the \link{ccr.GWclean} specifying the method used for p-value computation. For the "perm" method the p-value is based on full permutation. For the "hybrid" method the maximum over the entire region is split into maximum of max over small segments and max over the rest. Approximation is used for the larger segment max. Default is hybrid (see DNAcopy).
  }
  \item{min.width}{
    A numerical value used by the \link{ccr.GWclean} specifying the minimum number of markers for a changed segment. The default is 2 but can be made larger. Maximum possible value is set at 5 since arbitrary widths can have the undesirable effect of incorrect change-points when a true signal of narrow widths exists (see DNAcopy).
  }
  \item{kmax}{
    A numerical value used by the \link{ccr.GWclean} specifying the maximum width of smaller segment for permutation in the hybrid method (see DNAcopy). 25 by default.
  }
  \item{nmin}{
    A numerical value used by the \link{ccr.GWclean} specifying the minimum length of data for which the approximation of maximum statistic is used under the hybrid method. should be larger than 4*kmax (see DNAcopy). 200 by default.
  }
  \item{eta}{
    A numerical value used by the \link{ccr.GWclean} specifying the probability to declare a change conditioned on the permuted statistic exceeding the observed statistic exactly j (= 1,...,nperm*alpha) times. (see DNAcopy). 0.05 by default.
  }
  \item{trim}{
    A numerical value used by the \link{ccr.GWclean} specifying the proportion of data to be trimmed for variance calculation for smoothing outliers and undoing splits based on SD (see DNAcopy).
  }
  \item{undo.splits}{
    A character string used by the \link{ccr.GWclean} specifying how change-points are to be undone, if at all. Default is "none". Other choices are "prune", which uses a sum of squares criterion, and "sdundo", which undoes splits that are not at least this many SDs apart. (see DNAcopy).
  }
  \item{undo.prune}{
    A numerical value used by the \link{ccr.GWclean} specifying the proportional increase in sum of squares allowed when eliminating splits if undo.splits="prune" (see DNAcopy).
  }
  \item{undo.SD}{
    A numerical value used by the \link{ccr.GWclean} specifying the number of SDs between means to keep a split if undo.splits="sdundo" (see DNAcopy).
  }
  \item{nseed}{
    A numerical value used by the \link{ccr.GWclean} fixing the seed for the reproducibility of the results.
  }
  \item{run_mageck}{
    Boolean value specifying whether MAGeCK analysis [2] should be run on the counts file after the CRISPRcleanR correction [3]. 
    This function requires python and the MAGeCK python package (v0.5.3, available at: \url{https://sourceforge.net/projects/mageck/files/0.5/mageck-0.5.3.zip/download}) to be installed.
  }
  \item{path_to_mageck}{
    If run_mageck is set to TRUE and the MAGeCK location is not included in the path, this option should be used to specify the MAGeCK aplication file including the full path.
  }
  \item{is_web}{
    Technical parameter undocumented. Used for the integration in a web architecture.
  }
  \item{retrun_data}{
    Technical parameter undocumented. Used for the integration in a web architecture.
  }
  \item{verbose}{
    Technical parameter undocumented. Used for the integration in a web architecture.
  }
  \item{columns_map}{
    Technical parameter undocumented. Used for the integration in a web architecture.
  }
}

\value{
  A boolean value equal to TRUE if the function end without errors.
}
\references{

  [1] Tzelepis K, Koike-Yusa H, De Braekeleer E, et al \emph{A CRISPR dropout screen identifies genetic vulnerabilities and therapeutic targets in acute myeloid leukaemia}. Cell Reports 2016 Oct 18;17(4):1193-1205\cr

  [2] Li, W., Xu, H., Xiao, T., Cong, L., Love, M. I., Zhang, F., et al. (2014). MAGeCK enables robust identification of essential genes from genome-scale CRISPR/Cas9 knockout screens. Genome Biology, 15(12), 554.

  [3] Iorio, F., Behan, F. M., Goncalves, E., Beaver, C., Ansari, R., Pooley, R., et al. (n.d.). Unsupervised correction of gene-independent cell responses to CRISPR-Cas9 targeting. \cr 
  http://doi.org/10.1101/228189

}
\author{
Paolo Cremaschi (paolo.crmeaschi@fht.org)
}
\seealso{
\code{
  \link{ccr.CreateLibraryIndex}
  \link{ccr.FASTQ2counts}
  \link{ccr.BAM2counts}
  \link{ccr.NormfoldChanges}
  \link{ccr.GWclean}  
}}
\examples{\dontrun{
## Define the list of FASTQ files to used for the alignment
fileCount <- file.path(
  system.file("extdata", package = "CRISPRcleanR"),
  "HT-29_counts.tsv"
)

## Run the alignment and extract the raw counts
status <- ccr.AnalysisPipeline(
  file_counts = fileCount,
  outdir='./HT29_COUNTS/',
  EXPname = 'HT29_counts',
  library_builtin = "KY_Library_v1.1",
  run_mageck = FALSE,
  ncontrols = 1
)
}}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{analysis}% use one of  RShowDoc("KEYWORDS")

