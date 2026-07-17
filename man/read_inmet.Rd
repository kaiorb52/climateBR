\name{read_inmet}
\alias{read_inmet}
\title{Read INMET observations}
\usage{
read_inmet(
  path = NULL,
  years = NULL,
  stations = NULL,
  variables = NULL,
  collect = FALSE
)
}
\arguments{
\item{years}{Years to read.}

\item{stations}{WMO station codes.}

\item{variables}{Variables to return.}

\item{collect}{Should the result be collected into memory?}
}
\description{
Read INMET observations
}