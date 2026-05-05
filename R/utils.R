
check_dir <- function(path = "./data/"){
  if (dir.exists(path)){
    message(paste("Directory already exists:", path))
  } else {
    dir.create(path)
    message(paste("Directory created:", path))
  }
}

check_file <- function(path = "./data/"){
  if (file.exists(path)){
    message(paste("File already exists:", path, "(skipping download)"))
    return(TRUE)
  } else {
    message(paste("File not found:", path))
    return(FALSE)
  }
}
