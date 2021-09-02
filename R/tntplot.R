#' Use TnT to visualize a GRanges segment, assumes an mcols element 'score' is present, numeric-like
#' @param gr GRanges instance
#' @param scorecolor character(1) color used on PinTrack for scores
#' @param genecolor character(1) color used on GeneTrackFromTxDb for gene regions
#' @param gt optional GeneTrack to avoid recomputing; defaults to NULL
#' @param viewradius numeric(1) radius around given `gr` for display
#' @param coordradius numeric(1) radius around region to allow panning
#' @export
tntplot = function(gr, scorecolor="lightblue", genecolor="gold", gt=NULL, viewradius=100000, coordradius=200000) {
  if (!requireNamespace("TnT")) stop("install TnT to use this")
  if (!requireNamespace("GenomicRanges")) stop("install GenomicRanges to use this")
  if (is.null(gt)) gt = TnT::GeneTrackFromTxDb(TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene,
                                               height=100, color=genecolor)  # consider making this optionally passed as a fixed object
  suppressMessages({
    syms = AnnotationDbi::mapIds(org.Hs.eg.db::org.Hs.eg.db, keys=gt@Data$id, keytype="ENTREZID", column="SYMBOL")
  })
  gt@Data$display_label = TnT::strandlabel(syms, GenomicRanges::strand(gt@Data))
  tab = as.data.frame(gr) #t2g = tab2grngs(tab)
  tab$value = gr$score
  pt = TnT::PinTrack( gr, height=400, tooltip = as.data.frame(tab), color=scorecolor )
  TnT::TnTGenome(list(pt, gt), view.range=(range(gr)+viewradius), coord.range=GenomicRanges::ranges(range(gr)+coordradius)[1])
}
