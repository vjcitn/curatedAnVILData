library(shiny)
library(curatedAnVILData)
library(GenomicFiles)
library(rtracklayer)
library(TnT)
library(BiocParallel)
register(MulticoreParam(4))
data(gr38s)
data(msig_emt)
data(empfib_GF)
okgenes = intersect(names(gr38s), msig_emt)
query_radius = 100000

ui = fluidPage(
 sidebarLayout(
  sidebarPanel(
   helpText("Select gene to compare bigWig scores between GTEx Lung samples"),
   helpText("Top 5 traces are annotated with emphysema, bottom 5 with fibrosis"),
   selectInput("sym", "symbol", choices=sort(okgenes), selected="SERPINE1"),
   width=2),
 mainPanel(
	  textOutput("gene"),
   TnTOutput("tnt")
   ),
  )
 )

server = function(input, output) {
output$gene = renderText(paste("emphysema - fibrosis comparison for", input$sym) )
output$tnt = renderTnT({
  query = input$sym
  rng = gr38s[ query ] + query_radius
  rowRanges(empfib_GF) = rng
  imp = reduceByFile( empfib_GF[,c(1:5,11:15)], MAP=function(range, file) rtracklayer::import( file, which=range ))
  imp = lapply(imp, "[[", 1) # because of reduceByFile
  multitnt( imp, viewradius=5000, coordradius=10000, sheight=50 )
 })
}

runApp(list(ui=ui, server=server))
