#' simple emendation of tntplot to handle multiple GRanges, stacked
#' @param grl list of GRanges
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
#' it can slow initialization, but for now it is imported by package.  Note that all input
#' GRanges are reduced to width-1 midpoint.
#' @export
multitnt = function (grl, scorecolor = "lightblue", genecolor = "gold", 
    gt = NULL, viewradius = 1e+05, coordradius = 2e+05, gheight = 200, 
    sheight = 200, confine = TRUE, score2val = TRUE) 
{
    if (!requireNamespace("TnT")) 
        stop("install TnT to use this")
    if (!requireNamespace("GenomicRanges")) 
        stop("install GenomicRanges to use this")
    if (is.null(gt)) 
        gt = TnT::GeneTrackFromTxDb(TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene, 
            height = gheight, color = genecolor)
    suppressMessages({
        syms = AnnotationDbi::mapIds(org.Hs.eg.db::org.Hs.eg.db, 
            keys = gt@Data$id, keytype = "ENTREZID", column = "SYMBOL")
    })
    gt@Data$display_label = TnT::strandlabel(syms, GenomicRanges::strand(gt@Data))
    ptl = list()
    for (i in seq_len(length(grl))) {
        gr = keepStandardChromosomes(grl[[i]], pruning.mode = "coarse")
        if (confine) 
            start(gr) = end(gr) = 0.5 * (start(gr) + end(gr))
        gr$value = gr$score
        tab = as.data.frame(gr)
        ptl[[i]] = TnT::PinTrack(gr, height = sheight, tooltip = as.data.frame(tab), 
            color = scorecolor)
    }
    TnT::TnTGenome(c(ptl, gt), view.range = (range(gr) + viewradius), 
        coord.range = GenomicRanges::ranges(range(gr) + coordradius)[1])
}
