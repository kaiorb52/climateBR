\name{build_inmet_dataset}
\alias{build_inmet_dataset}
\title{Build an INMET Arrow dataset}
\usage{
  build_inmet_dataset(input, output)
}
\arguments{
  \item{input}{Directory containing the downloaded CSV files.}
  
  \item{output}{Directory where the Parquet dataset will be written.}
}
\description{
  Convert downloaded INMET CSV files into a partitioned Parquet dataset.
}
