\name{download_inmet}
\alias{download_inmet}
\title{Download Data from INMET}
\usage{
download_inmet(
  years    = 2008,
  unzip_to = getwd()
)
}
\arguments{
  \item{years}{
    Integer vector specifying the years for which data should be downloaded.
    The database is available from 2000 onwards; Defaults to \code{2010:2014}.
  }
  \item{unzip_to}{
    Character string specifying the directory path where the downloaded
    files will be extracted.
  }
}
\description{
Downloads meteorological station data from INMET (Brazil's National Institute
of Meteorology). The database covers records starting from the year 2000;
however, only 5 stations were available in that initial year (one per Brazilian
region). Thus, we recommend using data from 2008 onwards, when the station network
had expanded substantially.
}
\examples{
\dontrun{

## Download data from a single year
download_inmet(
  years    = 2000,
  unzip_to = "./"
)

## Download data from multiples years
download_inmet(
  years    = 2008:2010,
  unzip_to = "./"
)

}
}

