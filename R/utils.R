
check_dir <- function(path){
  if (!dir.exists(path)){
    dir.create(path)
  }
}

check_file <- function(path){
  if (file.exists(path)){
    return(TRUE)
  } else {
    return(FALSE)
  }
}
