tab_assays = function(tissue="Lung") {
  data("GTExMAE", package="curatedAnVILData")
  ok_tiss = names(rownames(GTExMAE))
  if (!(tissue %in% ok_tiss)) stop("tissue not in names(rownames(GTExMAE))")
  GTExMAE[,,tissue][[1]] |> colData() |> 
        as.data.frame() |> group_by(sequencing_assay) |> summarise(n=n())
}