# curatedAnVILData
prototype for AnVIL-Bioc symbiosis

## Overview

This workspace illustrates structuring and filtering of Gen3 PFB:Terra exports with AnVIL functions.

This started out as a jupyter-oriented workspace, and a jupyter
notebook is available in the workspace.  But in August 2021 the jupyter notebook
was manually migrated to R markdown, and then to an R package, managed in github.

We started out with a selection of records using the explorer at
gen3.theanvil.io, making selections from the "CF-GTEx" project, and
'exporting to Terra'.

Here's an example of some of the R programming underlying resources
in this workspace:.

```
seqtab = avtable(table="sequencing")
table(seqtab$`pfb:data_type`, seqtab$`pfb:data_format`)
##                             
##                                bai   bam bigWig  crai  cram fastq  junc   svs
##   Aligned Reads              15512 15783  13803   667   667     0     0     0
##   Allele Specific Expression     0     0      0     0     0     0     0     0
##   Histology                      0     0      0     0     0     0     0 18781
##   Junction Files                 0     0      0     0     0     0 12132     0
##   Unaligned Reads                0     0      0     0     0   351     0     0
##                             
##                                tab   tsv   txt
##   Aligned Reads                  0     0     0
##   Allele Specific Expression     0  1236  1236
##   Histology                      0     0     0
##   Junction Files                 0     0     0
##   Unaligned Reads            14781     0     0
```

Vignettes will demonstrate, emulation of curatedTCGAData
with respect to convenience of identifying and filtering key data components of AnVIL.

## Resources for R programming

### A MultiAssayExperiment

#### Concept

The MultiAssayExperiment class unites diverse 'assays' collected on
a collection of samples.

<img alt="wordcloud" title="pathology notes wordcloud" src="https://storage.googleapis.com/bioc-anvil-images/MAEschema.png" width=900>

That's from the [MultiAssayExperiment vignette](https://bioconductor.org/packages/release/bioc/vignettes/MultiAssayExperiment/inst/doc/MultiAssayExperiment.html).  See also
the [JCO CCI paper](https://ascopubs.org/doi/full/10.1200/CCI.19.00119).

#### An example

After `curatedAnVILData` has been installed, acquire metadata
about a selection of GTEx samples via
```
suppressPackageStartupMessages(
  library(curatedAnVILData)
	)
data(GTExMAE)
GTExMAE
```

The `GTExMAE` has 30 "experiments" corresponding to types
of tissue that were subjected to RNA sequencing.

```
A MultiAssayExperiment object of 30 listed
 experiments with user-defined names and respective classes.
 Containing an ExperimentList class object of length 30:
 [1] Skin: SummarizedExperiment with 0 rows and 7206 columns
 [2] Lung: SummarizedExperiment with 0 rows and 3055 columns
 [3] Thyroid: SummarizedExperiment with 0 rows and 2743 columns
 [4] Adipose Tissue: SummarizedExperiment with 0 rows and 4853 columns
 [5] Blood Vessel: SummarizedExperiment with 0 rows and 5770 columns
 [6] Esophagus: SummarizedExperiment with 0 rows and 6226 columns
 [7] Blood: SummarizedExperiment with 0 rows and 6787 columns
 [8] Heart: SummarizedExperiment with 0 rows and 3623 columns
 [9] Nerve: SummarizedExperiment with 0 rows and 2532 columns
 [10] Colon: SummarizedExperiment with 0 rows and 3420 columns
 [11] Brain: SummarizedExperiment with 0 rows and 9807 columns
 ...
 ```
 
 #### Interrogating an MAE
 
 The variety of sequencing tasks for lung:
 
 ```
 GTExMAE[,,"Lung"][[1]] |> colData() |> as.data.frame() |> group_by(sequencing_assay) |> summarise(n=n())
 ```
 
 The result is chatty:
 ```
 harmonizing input:
  removing 72685 sampleMap rows not in names(experiments)
  removing 72685 colData rownames not in sampleMap 'primary'
 A tibble: 4 × 2
  sequencing_assay     n
  <chr>            <int>
1 RNA-Seq           2737
2 WES                 24
3 WGS                 20
4 NA                 274
Warning message:
'experiments' dropped; see 'metadata' 
 ```
 
 #### Filtering an MAE

We can create a selection of bigWig files measuring
mRNA abundance in lung via:

```
lungbw = GTExMAE[,,"Lung"][[1]] |> colData() |> filter(data_category=="Transcriptome Profiling" & data_format == "bigWig") 
```


Some interesting sample-level metadata is available in free text:
```
head(lungbw |> select(pathology_notes_prc) |> unlist() |> unname(),10)
```
```
 [1] "2 pieces, mild congestion, partially sloughing bronchial mucosa delineated"                                                                                
 [2] "2 pieces  ~1x7mm.  Abundant vessels, bronchial/bronchiolar epithelial elements present, encircled.  Minute focus of bronchial cartilage in one, delineated"
 [3] "2 pieces; emphysema; mild fibrosis; congestion; bronchus with cartilage in 1 piece"                                                                        
 [4] "2 pieces; patchy emphysema; pleura sampled [annotated]"                                                                                                    
 [5] "2 pieces, moderate congestion/alveolar edema"                                                                                                              
 [6] "2 pieces; mild emphysema"                                                                                                                                  
 [7] "2 pieces, 9x7 & 8x8mm; mild congestion; bronchioles well visualized, rep ones delineated, fairly well preserved"                                           
 [8] "2 pieces, marked congestion. Hyaline cartilage foci present, rep delineated"                                                                               
 [9] "2 pieces; atelectasis, focal smooth muscle hypertrophy and increased mucosal goblet cells"                                                                 
[10] "2 pieces; bronchus and large blood vessel comprise 50% of 1 piece" 
```

With the wordcloud2 R package and some hints from a [blog post](https://towardsdatascience.com/create-a-word-cloud-with-r-bde3e7422e8a),
we can summarize the content of these pathology notes:

<img alt="wordcloud" title="pathology notes wordcloud" src="https://storage.googleapis.com/bioc-anvil-images/lungWCloud.png" width=500>



### Working with DRS URI

```
> lungbw$ga4gh_drs_uri[1]
[1] "drs://dg.ANV0:dg.ANV0/c19b5318-4b0b-4585-b833-cdf927f0ddfc"
> AnVIL::drs_stat(.Last.value)
# A tibble: 1 × 10
  fileName         size contentType  gsUri          timeCreated  timeUpdated  bucket   name         googleServiceAc… hashes
  <chr>           <int> <chr>        <chr>          <chr>        <chr>        <chr>    <chr>        <list>           <list>
1 GTEX-13X6K-1…  1.76e8 application… gs://fc-secur… 2020-07-08T… 2020-07-08T… fc-secu… GTEx_Analys… <named list [1]> <name…
> .Last.value |> as.data.frame()
                                                              fileName      size      contentType
1 GTEX-13X6K-1626-SM-7EWCX.Aligned.sortedByCoord.out.patched.md.bigWig 175687253 application/json
                                                                                                                                                                     gsUri
1 gs://fc-secure-ff8156a3-ddf3-42e4-9211-0fd89da62108/GTEx_Analysis_2017-06-05_v8_RNAseq_bigWig_files/GTEX-13X6K-1626-SM-7EWCX.Aligned.sortedByCoord.out.patched.md.bigWig
               timeCreated              timeUpdated                                         bucket
1 2020-07-08T18:46:07.637Z 2020-07-08T18:46:07.637Z fc-secure-ff8156a3-ddf3-42e4-9211-0fd89da62108
                                                                                                                  name
1 GTEx_Analysis_2017-06-05_v8_RNAseq_bigWig_files/GTEX-13X6K-1626-SM-7EWCX.Aligned.sortedByCoord.out.patched.md.bigWig
```
We can use `AnVIL::gsutil_cp` on the `gsUri` obtained above, to materialize the bigWig for local analysis.

Eventually region-based queries can be conducted over HTTP within AnVIL.

### Visualizing imported bigWig

We produced the following display (it is interactive when produced in RStudio) using the tntplot function in curatedAnVILData.
This takes a GRanges as input; the regions must have width 1 and an mcols field 'value' must be present.

<img alt="coverage" title="TnT coverage sketch" src="https://storage.googleapis.com/bioc-anvil-images/tntplotAnVIL.png" width=800>

### Exercise 1 for Sept. 7

Form a MAE-level colData with selected variables, bind to GTExMAE, and demonstrate its use for cross-tissue selection.

#### Solution

Here is a function for this task;

```
add_cd = function(mae, kpvar=NULL) {
  allcds = lapply(experiments(mae), colData)
  fullm = do.call(rbind, allcds)
	if (!is.null(kpvar)) {
	     fullm = fullm[,kpvar]
			 }
	colData(mae) = fullm
	mae
}
```

Add complete colData to GTExMAE:

```
> colData(GTExMAE)
DataFrame with 75740 rows and 0 columns
> gt2 = add_cd(GTExMAE)
> dim(colData(gt2))
[1] 75740   270
```

Limit to samples for which ischemic time exceeds 1400 minutes:

```
> gt2[, which(gt2$ischemic_time_in_minutes>1400), ]
harmonizing input:
  removing 9 sampleMap rows with 'colname' not in colnames of experiments
A MultiAssayExperiment object of 30 listed
 experiments with user-defined names and respective classes.
 Containing an ExperimentList class object of length 30:
 [1] Skin: SummarizedExperiment with 0 rows and 31 columns
 [2] Lung: SummarizedExperiment with 0 rows and 10 columns
 [3] Thyroid: SummarizedExperiment with 0 rows and 20 columns
 [4] Adipose Tissue: SummarizedExperiment with 0 rows and 35 columns
 [5] Blood Vessel: SummarizedExperiment with 0 rows and 42 columns
 [6] Esophagus: SummarizedExperiment with 0 rows and 50 columns
 ...
 ```
 

### Exercise 2 for Sept. 7

Compare expression patterns for selected genes (provide a shiny app) in lung samples annotated with either fibrosis or emphysema.

<img alt="coverage" title="TnT coverage sketch" src="https://storage.googleapis.com/bioc-anvil-images/tracks.png" width=800>

