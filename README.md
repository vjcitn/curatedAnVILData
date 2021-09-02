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
 [1] Skin: tbl_df with 7272 rows and 270 columns
 [2] Lung: tbl_df with 3171 rows and 270 columns
 [3] Thyroid: tbl_df with 2814 rows and 270 columns
 [4] Adipose Tissue: tbl_df with 4888 rows and 270 columns
 [5] Blood Vessel: tbl_df with 5849 rows and 270 columns
 [6] Esophagus: tbl_df with 6231 rows and 270 columns
 [7] Blood: tbl_df with 7383 rows and 270 columns
 [8] Heart: tbl_df with 3689 rows and 270 columns
 ...
 ```

We can create a selection of bigWig files measuring
mRNA abundance in lung via:
```
lungbw = GTExMAE |> expt("Lung") |> simplify_names() |> 
  filter(data_category=="Transcriptome Profiling" & data_format == "bigWig") 
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


### Visualizing imported bigWig

![tntplot](https://storage.googleapis.com/bioc-anvil-images/tntplotAnVIL.png)
