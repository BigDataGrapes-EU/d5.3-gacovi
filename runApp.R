library(plumber)

plumb("./server/api.R") %>% 
  pr_static("/", "../client/public") %>% 
  pr_set_docs(FALSE) %>% 
  pr_run(host="0.0.0.0", port=80)
