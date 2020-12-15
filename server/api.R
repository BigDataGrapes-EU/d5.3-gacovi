library(plumber)
library(data.table)
library(seriation)

#* @apiTitle GaCoVi API

#* @filter cors
cors <- function(req, res) {
  
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }
  
}

#* Adds order attribute to mvn's nodes for GaCoVi
#* @param mvn a json with the nodes and edges of an mvn
#* @post /order
function(mvn){
  setDT(mvn$edges)
  setDT(mvn$nodes)

  if (nrow(mvn$nodes) > 2) {
    setorder(mvn$nodes, id)
    
    adj_matrix <- dcast(
      mvn$edges, from ~ to, value.var = "weight"
    )
    setorder(adj_matrix, from)
    setcolorder(adj_matrix, c("from", adj_matrix[,from]))
    
    d_matrix <- as.dist(
      adj_matrix[, -"from"
                 ][, lapply(.SD, function(x) 1 - abs(x))]
    )
    
    seriation <- seriate(d_matrix, method = "BBWRCG") 
    mvn$nodes <- mvn$nodes[get_order(seriation),  ]
  }

  mvn$nodes[,order := .I][]
  return(mvn)
}

#* @assets ./public
list()
