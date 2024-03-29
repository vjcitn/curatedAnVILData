library(AnVIL)
library(dplyr)
library(curatedAnVILData) # for simplify_names
samp = avtable(table="sample")
subj = avtable(table="subject")
seqtab = avtable(table="sequencing")
alltypes = unique(samp$`pfb:tissue_type`)
tissframes = lapply(na.omit(alltypes), function(x) samp |> filter(`pfb:tissue_type` == x))
names(tissframes) = na.omit(alltypes)
library(MultiAssayExperiment)
# by stages
t2 = lapply(tissframes, function(x) mutate(x, subject_id=`pfb:subject`))
t3 = lapply(t2, function(x) left_join(x, subj, by="subject_id"))
sqsq = mutate(seqtab, sample_id=`pfb:sample`)
t4 = lapply(t3, function(x) inner_join(sqsq, x, by="sample_id"))
fullmeta = t4
library(SummarizedExperiment)
mkse = function (x) 
{
  x = simplify_names(x)
  x = DataFrame(x)
  rownames(x) = x$sequencing_id
  SummarizedExperiment(assay = SimpleList(ph = matrix(NA, nr = 0, 
                                                      nc = nrow(x))), colData = x)
}
ses = lapply(fullmeta, function(x) mkse(x))
GTExMAE = MultiAssayExperiment(ExperimentList(ses))
