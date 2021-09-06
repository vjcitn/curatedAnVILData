#' Use TnT to visualize a GRanges segment, assumes an mcols element 'score' is present, numeric-like
#' @importFrom AnnotationDbi mapIds
#' @import TnT
#' @import TxDb.Hsapiens.UCSC.hg38.knownGene
#' @import GenomicRanges
#' @importFrom GenomeInfoDb keepStandardChromosomes
#' @param gr GRanges instance
#' @param scorecolor character(1) color used on PinTrack for scores
#' @param genecolor character(1) color used on GeneTrackFromTxDb for gene regions
#' @param gt optional GeneTrack to avoid recomputing; defaults to NULL
#' @param viewradius numeric(1) radius around given `gr` for display
#' @param coordradius numeric(1) radius around region to allow panning
#' @param gheight numeric(1) display height for gene track
#' @param sheight numeric(1) display height for score track 
#' @param confine logical(1) if TRUE, set ranges to length 1 midpoint of given range
#' @param score2val logical(1) if TRUE, add 'value' as mcols element, taking content from 'score'
#' @note This is very preliminary design.  We may withdraw import of GenomicRanges because
#' it can slow initialization, but for now it is imported by package.
#' @export
tntplot = function(gr, scorecolor="lightblue", genecolor="gold", gt=NULL, viewradius=100000, coordradius=200000,
  gheight=200, sheight=200, confine=TRUE, score2val=TRUE) {
  if (!requireNamespace("TnT")) stop("install TnT to use this")
  if (!requireNamespace("GenomicRanges")) stop("install GenomicRanges to use this")
  if (score2val) gr$value = gr$score
  if (is.null(gt)) gt = TnT::GeneTrackFromTxDb(TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene,
                                               height=gheight, color=genecolor)  # consider making this optionally passed as a fixed object
  suppressMessages({
    syms = AnnotationDbi::mapIds(org.Hs.eg.db::org.Hs.eg.db, keys=gt@Data$id, keytype="ENTREZID", column="SYMBOL")
  })
  gt@Data$display_label = TnT::strandlabel(syms, GenomicRanges::strand(gt@Data))
  tab = as.data.frame(gr) #t2g = tab2grngs(tab)
  #tab$value = gr$score
  gr = keepStandardChromosomes(gr, pruning.mode="coarse")
  if (confine) start(gr) = end(gr) = .5*(start(gr)+end(gr)) # thanks gUtils/mskilab
  pt = TnT::PinTrack( gr, height=sheight, tooltip = as.data.frame(tab), color=scorecolor )
  TnT::TnTGenome(list(pt, gt), view.range=(range(gr)+viewradius), coord.range=GenomicRanges::ranges(range(gr)+coordradius)[1])
}
